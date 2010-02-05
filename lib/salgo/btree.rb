# 
# The MIT License
# 
# Copyright (c) 2010 Samuel R. Baskinger
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 

module Salgo
    
    class Btree
        
        class Node
            attr_reader :keys, :nodes
            attr_writer :keys, :nodes
            
            def initialize()
                @keys  = []
                @nodes = []
            end

            # Assume we have enough space to insert in the node.
            # If two sub-trees are specified, it is assumed that they are replacing the subtree
            # that the new_key was in. That sub-tree is replaced with the left_node
            # and the right_node is inserted after the left_node's index.
            def insert(new_key, left_node=nil, right_node=nil)
                
                # Caution code.
                throw Exception.new(
                    "Both right and left nodes must be nil or defined. One is not: #{right_node} #{left_node}") if (
                        right_node.nil? ^ left_node.nil? )
                
                insertion_point = 0
                
                catch(:foundI) do
                    @keys.each_with_index do |node_key, index| 
                        if ( new_key < node_key )
                            insertion_point = index
                            throw :foundI
                        end
                    end
                    
                    insertion_point = @keys.size
                end
                
                @keys.insert(insertion_point, new_key)
                @nodes[insertion_point] = left_node if left_node
                @nodes.insert(insertion_point+1, right_node) if right_node
                
            end
            
            # This node will split itself and return a list of 3 items, [key, left_node, right_node ].
            def split()
                
                node_partition = @nodes.size / 2
                key_partition = @keys.size / 2
                
                left_node = Node.new()
                right_node = Node.new()
                
                left_node.nodes = @nodes[0...node_partition]
                right_node.nodes = @nodes[node_partition..-1]

                left_node.keys = @keys[0...key_partition]
                right_node.keys = @keys[key_partition+1..-1]
                
                [ @keys[key_partition], left_node, right_node ]
            end
            
            def leaf?()
                @nodes.size == 0
            end
            
            # Similar to find_node_containing_key, but
            # considers keys as they node is iterated through.
            # An array of Salgo::Btree::Node or Salgo::Btree::Key object will be returned with the second element
            # set to the index of the node.
            #
            # If it is a key, then the key holds a match. If a node, then the node
            # subtree that should be expanded and searched.
            def find_node_or_key_containing_key(key)

                @keys.each_with_index do |node_key, i|
                    if ( key == node_key )
                        return [ node_key, i ]
                    elsif ( key < node_key )
                        return [ @nodes[i], i ]
                    end
                end

                return [ @nodes[-1], @nodes.size - 1 ]
            end
            
            def find_node_containing_key(key)
                @keys.each_with_index do |node_key, i|
                    if ( key < node_key )
                        return @nodes[i]
                    end
                end
                    
                # If no throw, we assign the last node because key is bigger (or equal to) all our keys.
                return @nodes[-1]
            end
            
            # Return an array of the min-key and min-node from this node.
            # There may or may not be a min-node.
            def take_min()
                [ @keys.shift, @nodes.shift ]
            end
            
            def take(index)
                [ @keys.delete_at(index), @nodes.delete_at(index) ]
            end
            
            # Return an array of the max-key and the max-node from this node.
            # There may or may not be a max-node.
            def take_max()
                [ @keys.pop, @nodes.pop ]
            end
            
            def put_max(key, node)
                @keys.push(key)
                @nodes.push(node) if node
            end
            
            def put(index, key, node)
                @keys.insert(index, key)
                @nodes.insert(index, node) if node
            end
            
            def put_min(key, node)
                @keys.unshift(key)
                @nodes.unshift(node) if node
            end
            
            def last_node?(node)
                @nodes[-1].equal?(node)
            end
            
            def first_node?(node)
                @nodes[0].equal?(node)
            end
            
        end
        
        # The key value should support >, < and ==.
        class Key
            attr_reader :val, :key
            attr_writer :val, :key
            
            def initialize(key, val=true)
                @key = key
                @val = val
            end
            
            def < (k)
                @key < k.key
            end
            
            def > (k)
                @key > k.key
            end
            
            def == (k)
                @key == k.key
            end
            
        end
        
        attr_reader :size
        
        def initialize(minnodes=2)
            @minnodes = ( minnodes < 2 )? 2 : minnodes
            @maxnodes = 2 * minnodes
            @root     = Node.new()
            @size     = 0
        end
        
        def root?(node) 
            @root.equal? node 
        end
        
        def full?(node)
            node.keys.size == @maxnodes-1
        end
        
        # Does the given node have enough keys (and perhaps nodes) to merge with another node?
        def mergable?(node)
            node.keys.size < @minnodes
        end
        
        def has_minimum_keys?(node)
            node.keys.size < @minnodes
        end
        
        # Is there an extra key to take, should we need it.
        def has_extra_keys?(node)
            node.keys.size >= @minnodes
        end
        
        def split_root
            node = Node.new()
            
            node.insert(*@root.split())
            
            @root = node
        end
        
        # Insert a new value at the given key. Duplicate values are allowed in this data structure
        # and insert does not prevent them. The []= method will replace values.
        def insert(key, val)
            key = Key.new(key, val)
            
            # Always make sure our special friend "root" is OK and has room for an insert.
            split_root if full?(@root)

            parent_node = nil
            node = @root

            not_inserted = true
            
            while(not_inserted)
                if ( full? node )
                        
                    median_key, lnode, rnode = node.split()
                    
                    # NOTE: Because we always split full root nodes, we will never enter here with parent_node=nil
                    # Oh good, we can do a normal split and insert the result in the parent.
                    parent_node.insert(median_key, lnode, rnode)
                    
                    if ( key < median_key )
                        node = lnode
                    else
                        node = rnode
                    end
                end
                
                # Can we insert?
                if ( node.leaf? )
                    node.insert(key)
                    @size += 1
                    not_inserted = false
                else
                    # which node to examine?
                    parent_node = node
                    node = node.find_node_containing_key(key)
                end
            end
        end
        
        def find_key(key)

            node = @root

            candidate, candidate_idx = node.find_node_or_key_containing_key(key)

            while( ! candidate.nil?)
                if ( candidate.is_a?(Key) )
                
                    return candidate
                end
                
                node = candidate
                candidate, candidate_idx = node.find_node_or_key_containing_key(key)
            end
            
            return nil
        end
        
        def find(key)
            k = find_key(Key.new(key, nil))
            
            (k.nil?) ? nil : k.val
        end

        # Given the parent node and the child_index of a child node,
        # this method will merge with the sibling to the left of the
        # child. The resulting "unknown" tree will be placed on 
        # the left and the known-filled node will be placed in the child
        # node's current spot.
        # The new target node is returned.
        def merge_with_left(parent, child_index)
            
            child      = parent.nodes[child_index]
            sibling    = parent.nodes[child_index-1]
            node       = Node.new()
            
            node.nodes = sibling.nodes + child.nodes
            
            node.keys  = sibling.keys  + [ parent.keys[child_index-1] ] + child.keys
            parent.take(child_index-1)
            parent.nodes[child_index-1] = node
            node
        end

        # Same as merge_with_right, but the roles are reversed as
        # are the locations of the resulting subtrees.
        # The new target node is returned.
        def merge_with_right(parent, child_index)
            child      = parent.nodes[child_index]
            sibling    = parent.nodes[child_index+1]
            node       = Node.new()
            
            node.nodes =  child.nodes + sibling.nodes
            
            node.keys  = child.keys  + [ parent.keys[child_index] ] + sibling.keys
            parent.take(child_index)
            parent.nodes[child_index] = node
            node
        end
        
        # Delete from a subtree. We assume the node can withstand delete when called.
        # They key object is returned.
        def delete_max_key(node=@root)
            
            return nil if @size == 0

            if root?(node) and @root.keys.size == 0 and @root.nodes.size == 1
                @root = node = @root.nodes[0]
            end
            
            while(true) do
                if ( node.leaf? )
                    @size -= 1
                    return node.take_max()[0]
                else
                    
                    # Fix up the node before deleting from it.
                    if has_minimum_keys?(node.nodes[-1])
                        if has_minimum_keys?(node.nodes[-2])

                            node = merge_with_left(node, node.nodes.size-1)
                            
                        else

                            # Pull the max key and node from our "left" sibling.
                            # Make the left key be our parent and put the node
                            # in the minimum of the right tree node.
                            another_key, another_node = node.nodes[-2].take_max
                            
                            node.nodes[-1].put_min(node.keys[-1], another_node)
                            node.keys[-1] = another_key

                            node = node.nodes[-1]

                        end
                    else
                        node = node.nodes[-1]
                    end
                end
            end
        end
        
        # Delete from a subtree. We assume the node can withstand delete when called.
        # The key object is returned.
        def delete_min_key(node=@root)
            
            return nil if @size == 0
            
            if root?(node) and @root.keys.size == 0 and @root.nodes.size == 1
                @root = node = @root.nodes[0]
            end
            
            while(true) do
                if ( node.leaf? )
                    @size -= 1
                    return node.take_min()[0]
                else
                    # Fix up the node before deleting from it.
                    if has_minimum_keys?(node.nodes[0])
                        if has_minimum_keys?(node.nodes[1]) 
                            node = merge_with_right(node, 0)
                            
                        else

                            # Pull the min key and node from our "right" sibling.
                            # Make the right key be our parent and put the node
                            # in the minimum of the right tree node.
                            another_key, another_node = node.nodes[1].take_min
                            
                            node.nodes[0].put_max(node.keys[0], another_node)
                            node.keys[0] = another_key

                            node = node.nodes[0]
                        end
                    else
                        node = node.nodes[0]
                    end
                        
                end
            end
        end
        
        def delete_key(key, node=@root)
            
            candidate, candidate_idx = node.find_node_or_key_containing_key(key)
            
            return nil if candidate.nil?
            
            # Delete from this node.
            if ( candidate.is_a?(Key) )
                
                # If it's a simple delete...
                if node.leaf? 
                    node.keys.delete_at(candidate_idx)
                    @size -= 1
                    return candidate
                elsif has_extra_keys?(node.nodes[candidate_idx])
                    node.keys[candidate_idx] = delete_max_key(node.nodes[candidate_idx])
                    return candidate
                elsif has_extra_keys?(node.nodes[candidate_idx+1])
                    node.keys[candidate_idx] = delete_min_key(node.nodes[candidate_idx+1])
                    return candidate
                else
                    node = merge_with_right(node, candidate_idx)
                    
                    # The merge_with_right call left the root with no keys and 1 child node. 
                    # Replace the root and delete from the root.
                    @root = @root.nodes[0] if ( @root.nodes.size == 1 )

                    return delete_key(key, node)
                end
                
            elsif candidate.is_a?(Node)
                
                # Ensure that the node can sustain a delete BEFORE entering it...
                unless has_extra_keys?(candidate) 
                    
                    if ( node.first_node?(candidate) )
                        if ( has_extra_keys?(node.nodes[1]))
                            another_key, another_node = node.nodes[1].take_min
                            candidate.put_max(node.keys[0], another_node)
                            node.keys[0] = another_key
                        else
                            merge_with_right(node, candidate_idx)
                        end
                    #elsif ( node.last_node?(candidate) )
                    else
                        if ( has_extra_keys?(node.nodes[candidate_idx-1]) )
                            another_key, another_node = node.nodes[candidate_idx-1].take_max
                            candidate.put_min(node.keys[candidate_idx-1], another_node)
                            node.keys[candidate_idx-1] = another_key
                        else
                            merge_with_left(node, candidate_idx)
                        end
                    end
                end
                
                # If one of the above merges removed all keys from the root, then there is only 1 node.
                # Promote that node as the root.
                candidate = @root = @root.nodes[0] if ( @root.nodes.size == 1 )                    

                delete_key(key, candidate)                
            end
        end
        
        def delete(key)
            
            key = delete_key(Key.new(key))
            
            (key.nil?)? nil : key.val
        end
        
        alias [] find
        
        # Set the key in this tree to the given value.
        # If there is already a value at the given key, it is replaced and the old value is returned.
        # Nil is returned otherwise.
        def []=(key, val)

            k = find_key(Key.new(key))
            
            if ( k.nil? )
                insert(key, val)
                nil
            else
                v = k.val
                k.val = val
                v
            end
        end
        
        def each(node=@root, &call)
            
            proc_child = ( node.leaf?() )? lambda { |x| } : lambda { |child_node| each(child_node, &call) }
            
            index = 0 


            node.keys.each do |key|
                proc_child.call(node.nodes[index])
                
                call.call(key.key, key.val)
                
                index+=1
                
            end
            
            proc_child.call(node.nodes[index])
        end
        
        def has_key?(key)
            ! find_key(Key.new(key)).nil?
        end
        
        alias member? has_key?
        alias include? has_key?
        alias key? has_key?
        
        alias store []= 
    end
end

