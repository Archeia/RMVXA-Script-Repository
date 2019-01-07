=begin
#==============================================================================
 ** Event Command Tree
 Authors: Tsukihime
 Date: Dec 9, 2012
------------------------------------------------------------------------------
 ** Change log
 Dec 9, 2012
   - Initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free
------------------------------------------------------------------------------
 ** Description
 
 This script provides a data structure that will store a list of event
 commands as a binary tree, traversed in DFS pre-order, starting with the
 root, then the right child, and then the left child. The purpose of this
 class is to make it easy to manipulate event commands.
   
 The root of the tree is the first command in the list.
 A child on the left is the next command on the same level
 A child on the right is the next command that is one indent higher 
 
------------------------------------------------------------------------------
 ** Usage
 
 To create an event command tree, simply instantiate one, passing in
 a list of event command lists
 
   t = EventCommandTree.new(list)
   
 To flatten the tree back to a list of event commands, use the call

   t.flatten

 To indent a node, and all children rooted at that node, use the call
 
   t.indent(node, indent)
   
 You will still have to first obtain a pointer to the specific node that
 you want to indent, but after that it is easy.
 
 At this point, it is not very easy to manipulate an event tree, but hopefully
 more methods will be available to make it easy.
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_EventCommandTree"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module Event_Command_Tree
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================
module RPG
  class EventCommand
    attr_accessor :left          # next command in the same level
    attr_accessor :right         # next command one indent higher
    attr_accessor :parent        # previous command in the same level
  end
  
  def inspect
    return sprintf("Code: %d, Indent: %d, Parameters: %s", @code, @indent, @parameters)
  end
end

#===============================================================================
# The Event Command Tree class. Stores a list of event commands as a binary tree
#===============================================================================
class EventCommandTree
  attr_accessor :root       # first command in the event list

  #-----------------------------------------------------------------------------
  # Initialize the tree. If a list of commands is given, build the tree
  # rooted at the first commands
  #-----------------------------------------------------------------------------
  def initialize(cmds=nil)
    @root = RPG::EventCommand.new
    if cmds
      @root = build_tree(cmds[0], nil, cmds[1..-1])
    end
  end

  #-----------------------------------------------------------------------------
  # Build the tree.
  #-----------------------------------------------------------------------------
  def build_tree(root, parent=nil, cmds)
    root.parent = parent
    while next_cmd = cmds.shift
      case next_cmd.indent
      when root.indent + 1 # Branch, add to the right
        root.right = build_tree(next_cmd, root, cmds)
      when root.indent     # Same level, add to the left
        root.left = build_tree(next_cmd, root, cmds)
      when root.indent - 1 # Put cmd back, return to parent
        cmds.insert(0, next_cmd)
        return root
      end
    end
    return root
  end
  
  #-----------------------------------------------------------------------------
  # Indents every node in the tree rooted at the given node. Useful if you are
  # re-arranging branches
  #-----------------------------------------------------------------------------
  def indent(indent=1, node=@root)
    return unless node
    node.indent += indent
    indent(indent, node.right)
    indent(indent, node.left)
  end
  
  #-----------------------------------------------------------------------------
  # Return the next command from the given node
  #-----------------------------------------------------------------------------
  def next_code(node=@root, same_level=false)
  end
  
  #-----------------------------------------------------------------------------
  # Convert the tree into a list of commands
  #-----------------------------------------------------------------------------
  def flatten(root=@root, cmds=[], indent=0)
    return unless root
    # update the indent to be consistent with the tree just in case
    root.indent = indent
    
    # add it to the list of commands
    cmds.push(root)
    flatten(root.right, cmds, indent + 1)
    flatten(root.left, cmds, indent)
    return cmds
  end
  
  #-----------------------------------------------------------------------------
  # Print the tree in pre-order, BFS. Separate the command's indent from our
  # own indent to verify it is correct
  #-----------------------------------------------------------------------------
  def print_tree(root=@root, indent=0)
    return unless root
    if root == @root
      p "Event Command Tree" 
      p "indent, code -  parameters"
    end
    p sprintf("%d, %s %s - %s", root.indent, "   "*indent, root.code, root.parameters)
    print_tree(root.right, indent + 1)
    print_tree(root.left, indent)    
  end  
  def inspect
    print_tree
  end
end