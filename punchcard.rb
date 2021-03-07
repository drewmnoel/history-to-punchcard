require 'victor'
require 'csv'

# Simple die for now
abort("Usage: #{$0} .zsh_history output.svg") unless ARGV.length == 2

entries = Array.new(7) { Array.new(24, 0) }
File.open(ARGV[0], "r").each() do |line|
  line = line.encode("UTF-8", invalid: :replace)
  next unless line =~ /^:/
  t = Time.at(line.split(":")[1].strip.to_i)
  entries[t.wday][t.strftime("%H").to_i] += 1
end

RECT_SIZE = 40

svg = Victor::SVG.new(width: '1920', height: '1080', viewBox: "0 0 1120 370")

svg.build do
  xoff = 130
  yoff = 80
  g(font_size: 18, font_family: 'Helvetica', fill: '#555') do
    %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].each_with_index do |day, idx|
      text(day, x: xoff, y: yoff + (idx * RECT_SIZE), 'text-anchor': 'end')
    end
  end

  xoff = 160
  yoff = 50
  g(font_size: 18, font_family: 'Helvetica', fill: '#555') do
    0.upto 23 do |hour|
      text(hour, x: xoff + (hour * RECT_SIZE), y: yoff, 'text-anchor': 'middle')
    end
  end

  points = {}
  items_max = 0

  entries.each_with_index do |hours, day|
    hours.each_with_index do |nr_items, hour|
      key = day * 7 + hour * 23
      points[key] = nr_items
      items_max = [nr_items, items_max].max
    end
  end

  xoff = 160
  yoff = 80
  0.upto 6 do |day|
    0.upto 23 do |hour|
      point = points[day * 7 + hour * 23]
      radius = (RECT_SIZE / 2) * point / items_max.to_f
      x = xoff + hour * RECT_SIZE
      y = yoff + day * RECT_SIZE
      if radius <= 2
        circle(cx: x, cy: y, r: 2, fill: '#ccc')
      else
        circle(cx: x, cy: y, r: radius, fill: '#008')
      end
      rect(x: x - RECT_SIZE / 2,
           y: y - RECT_SIZE / 2,
           width: RECT_SIZE,
           height: RECT_SIZE,
           fill: 'transparent',
           style: { stroke_width: 1, stroke: '#ccc' }) do
           title("#{point} items")
      end
    end
  end

end

svg.save ARGV[1]
