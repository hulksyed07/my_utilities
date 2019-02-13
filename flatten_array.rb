def flattenArrayN(my_nest)
  # my_nest is a list, possibly nested, to ANY level
  my_flat = [] # initially empty, result list
  my_nest.each do |my_item|
    if my_item.is_a? Array
      # if we have a list, then extend the result
      # with a recursively flattened list
      flattenArrayN(my_item).each do |item|
        my_flat << item
      end
    else # otherwise append to the result, one item
      my_flat << my_item
    end
  end
  return my_flat
end

# a = flattenArrayN([1, 2, 3, 4])
a = flattenArrayN([1, 2, 3, [4, 5, 6]])

puts a
