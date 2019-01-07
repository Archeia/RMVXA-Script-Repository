      item_locations_array = [[2, 0], [2, 24], [2, 48], [2, 72], [2, 96]]
      actor.equips.each_with_index do |e,i|
        next unless e
        result.push(["$icon[#{e.icon_index}]", item_locations_array[i], 255])
        xp, yp = item_locations_array[i][0] + 24, item_locations_array[i][1]
        result.push([e.name, [xp,yp], [contents.width, 0], [255, 255, 255],
          [contents.font.name, contents.font.size, contents.font.bold,
          contents.font.italic], [0, 0, 0]])
      end
      
      result