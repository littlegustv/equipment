# Todo:
#
# - handle weird 'stats' like containers, spell charges
# - handle non-worn objects
# - weapons!

require 'nokogiri'
require 'open-uri'
require 'json'

wear_locations = [
  'arms','body','feet','finger','float','hands','head','hold','legs','light','neck','newbie','none','shield','torso','waist','wield','wrist'
]
pages = ["http://acaykath.awardspace.com/?page=equipment&minlevel=0&maxlevel=0&namecontains=&type=&wearloc=arms&stats="]
empty_stats = {
  "hp": 0,
  "mp": 0,
  "mv": 0,
  "hit": 0,
  "dam": 0,
  "str": 0,
  "dex": 0,
  "con": 0,
  "wis": 0,
  "int": 0,
  "sav": 0,
  "age": 0,
  "ac": 0,
  "damRed": 0,
  "sDam": 0,
  "atkSpd": 0
}
objects = []

wear_locations.each do |wear_location|

  puts "#{wear_location.capitalize}"
  page_url = "http://acaykath.awardspace.com/?page=equipment&minlevel=0&maxlevel=0&namecontains=&type=&wearloc=#{wear_location}&stats="
  doc = Nokogiri::HTML(open(page_url))

  columns = doc.css("table td.header").map(&:text)

  rows = doc.css("table tr")[1..-1].map{ |row| row.css("td").map(&:text) }

  rows.each do |row|
    object = {}
    columns.each_with_index do |column, index|
      if column == "Stats"
        stats, flags = row[index].split(/\((.+)\)/)
        object["Flags"] = flags.to_s.split(" ")
        object["Stats"] = empty_stats.clone
        # AC
        stats = stats.to_s
        if ac = stats.match(/AC:(\d+\/\d+\/\d+\/\d+)/)
          object["Stats"]["AC"] = ac[1].split("/").map(&:to_i)
        else
          object["Stats"]["AC"] = [0,0,0,0]
        end
        stats.scan(/([\-\d]+)([a-zA-Z]+)/).each do |pair|
          object["Stats"][pair[1]] = pair[0]
        end
      elsif column == "Wear"
        if row[index]["newbie"]
          object["Newbie"] = true
        else
          object["Newbie"] = false
        end
        object["Wear"] = row[index].gsub("newbie", "").strip
      else
        object[column] = row[index]
      end
    end
    objects.push(object)
  end  
end

File.open("equipment.json", "w") do |f|
  f.write(objects.to_json)
end