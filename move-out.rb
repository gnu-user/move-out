#!/usr/bin/env ruby

###############################################################################
#
#  Move Out!
#
#  A script to help you in getting that certain-someone to move out!
#
#
#  Copyright (C) 2013, Jonathan Gillett
#  All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

require 'nokogiri'
require 'open-uri'

# Mediocre system, this needs to be improved
$mediocre_system = { :price => 600.00, 
                    :description => ['senior', 'washroom', 'female', 'woman', 'family'],
                    :location => ['scarborough', 'markham', 'toronto', 'etobicoke']}


class String
  def is_number?
    true if Float(self) rescue false
  end
end


# Get the URI to the real estate page on kijiji
def realestate_uri()
    page = Nokogiri::HTML(open('http://www.kijiji.com'))

    # Get the link to the real-estate page on kijiji
    page.css('a > h2.homeMetaCatName').each do |link|
        if link.content =~ /real\s+estate/i 
            #puts link
            #puts link.content
            return link.xpath('..').to_s.match(/href="(.*?)"/)[1]
        end
    end
end

# Return an array of the URIs to the rooms found on kijiji
def kijiji_rooms(page)
    # Array of the rooms found with URI to the room posting
    rooms_uri = []

    page.css('td.prc > strong').each do |item|
        price = item.content.strip

        # Return the link to the listing if price is below the specified price or as "Please contact"
        if (price.gsub(/[$,]/, '').is_number? and price.gsub(/[$,]/, '').to_f <= $mediocre_system[:price]) or price =~ /please\s+contact/i

            rooms_uri << item.xpath('../../td/a').to_s.match(/href="(.*?)"/)[1]
        end
    end

    return rooms_uri
end





# Get the main kijij page
page = Nokogiri::HTML(open(realestate_uri()))

# Iterate through each of rooms found and display the results
#rooms = { :url => {:price => 0.00 , :title => '', :location => '', :contact => []} }
rooms = {}

kijiji_rooms(page).each do |room_uri|
    page_room = Nokogiri::HTML(open(room_uri))

    location = ''
    description = ''

    # Add get the location and description 
    page_room.css('a.viewmap-link').each do |map_link|
        location = map_link.xpath('..').to_s.match(/<td>(.*)<br>/im)[1]
        location.strip!
    end

    page_room.css('span#preview-local-desc').each do |desc|
        description = desc.content.strip
        description.gsub!(/<br>/, '')
    end

    # If the location matches then add the room url to the dictionary
    $mediocre_system[:location].each do |cur_location|
        if location =~ /#{cur_location}/im
            rooms[room_uri] = {:uri => room_uri, :location => location}
            break
        end
    end

    # If the room did not match the location continue
    if rooms[room_uri].nil?
        next
    end

    # Add the ad title
    page_room.css('h1#preview-local-title').each do |item|
        title = item.content.to_s.strip
        rooms[room_uri][:title] = title
    end

    # Add the price of the room
    page_room.css('tr td.first_col + td[style]').each do |item|
        price = item.content.to_s.strip
        rooms[room_uri][:price] = price.gsub(/[$,]/, '')
    end

    # Add the contact information if found in the description
    if description =~ /\d{3}[-\s]{0,1}\d{3}[-\s]{0,1}\d{4}/im
        rooms[room_uri][:contact] = description.scan(/\d{3}[-\s]{0,1}\d{3}[-\s]{0,1}\d{4}/im)
    end
end

rooms.each do |key, value|
    puts "\nTITLE: #{value[:title]}"
    puts "PRICE: #{value[:price]}"
    puts "LOCATION: #{value[:location]}"
    puts "CONTACT: #{value[:contact]}"
    puts "URL: #{value[:uri]}\n"
end
