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

class String
  def is_number?
    true if Float(self) rescue false
  end
end


def kijiji_realestate()
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


# Mediocre system, this needs to be improved
mediocre_system = {:price => 600.00}


# Use the price factor of our mediocre system to identify potential housing
first_realestate_page = kijiji_realestate()

page = Nokogiri::HTML(open(first_realestate_page))

page.css('td.prc > strong').each do |item|
    
    price = item.content.strip

    # Return the link to the listing if price is below the specified price or as "Please contact"
    if (price.gsub(/[$,]/, '').is_number? and price.gsub(/[$,]/, '').to_f <= mediocre_system[:price]) or price =~ /please\s+contact/i
        puts price.gsub(/[$,]/, '')
    end
end