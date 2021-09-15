class Array
  def to_linked_list
    node = nil
    each do |e|
      if node
        node.append(e.to_link_node)
      else
        node = e.to_link_node
      end
    end
    node
  end
end
