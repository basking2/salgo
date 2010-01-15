require 'test/unit'

require 'salgo/btree'

require 'pp'

class BTreeTest < Test::Unit::TestCase
    include Salgo
    
    def test_nodeinsert()
        assert(true, "OK")
        
        n = Btree::Node.new()
        
        begin
            n.insert(1, 2)
            assert(false, "Failed to report undefined right or left subtree.")
        rescue Exception => e
            assert(true, "Caught expected exception.")
        end
            
        n.insert(1, 2, 3)
        assert(n.nodes[0] == 2)
        assert(n.nodes[1] == 3)
        assert(! n.nodes[0].nil?)
    end
    
    def test_nodesplit()
        n = Btree::Node.new()
        n.nodes = [1,1,3,3]
        n.keys = [1,2,3]
        key, lnode, rnode = n.split()
        assert(key == 2, "Key was #{key}")
        assert(lnode.keys==[1])
        assert(rnode.keys==[3])
        assert(lnode.nodes==[1,1])
        assert(rnode.nodes==[3,3])
        
        n2 = Btree::Node.new()
        
        n2.insert(*n.split())
        
        assert(n2.keys[0]==2)
        assert(n2.nodes[0].keys==[1])
        assert(n2.nodes[1].keys==[3])
        assert(n2.nodes[0].nodes==[1,1])
        assert(n2.nodes[1].nodes==[3,3])
    end
    
    def test_find_node_containing_key()
        n = Btree::Node.new()
        
        n.keys = [Btree::Key.new(1,1), Btree::Key.new(2,2), Btree::Key.new(3,3)]
        n.nodes = [ Btree::Node.new(), Btree::Node.new(), Btree::Node.new(), Btree::Node.new() ]

        assert(n.find_node_containing_key(Btree::Key.new(0)).equal? n.nodes[0])
        assert(n.find_node_containing_key(Btree::Key.new(1)).equal? n.nodes[1])
        assert(n.find_node_containing_key(Btree::Key.new(2)).equal? n.nodes[2])
        assert(n.find_node_containing_key(Btree::Key.new(3)).equal? n.nodes[3])
    end
    
    def test_split()
        bt = Btree.new()
        bt.insert(1, 1)
        bt.insert(2, 2)
        bt.insert(3, 3)
        rt = bt.instance_variable_get("@root")

        key, lnode, rnode = rt.split()
        
        assert(key.val == 2)
        assert(lnode.keys[0].val == 1)
        assert(rnode.keys[0].val == 3)
    end
    
    def test_insert()
        bt = Btree.new()
        bt.insert(1, 'a')
        bt.insert(2, 'b')
        bt.insert(3, 'c')
        bt.insert(4, 'd')
        bt.insert(5, 'e')
        bt.insert(6, 'f')
        
        assert(bt.size == 6, "Size was not 5 but #{bt.size}")
        
        rt = bt.instance_variable_get("@root")
        
        assert(rt.nodes[0].keys[0].key == 1)
        assert(rt.keys[0].key == 2)
        assert(rt.nodes[1].keys[0].key == 3)
        assert(rt.keys[1].key == 4)
        assert(rt.nodes[2].keys[0].key == 5)
        assert(rt.nodes[2].keys[1].key == 6)
        
        assert(bt.find(1) == 'a')
        assert(bt.find(2) == 'b')
        assert(bt.find(3) == 'c')
        assert(bt.find(4) == 'd')
        assert(bt.find(5) == 'e')
        assert(bt.find(6) == 'f')
    end
    
    def test_delete_max_key()
        bt = Btree.new()
        bt.insert(1, 'a')
        bt.insert(2, 'b')
        bt.insert(3, 'c')
        bt.insert(4, 'd')
        bt.insert(5, 'e')
        bt.insert(6, 'f')
        
        assert(bt.size == 6, "Size was not 5 but #{bt.size}")
        
        assert(bt.delete_max_key().val == 'f')
        assert(bt.delete_max_key().val == 'e')
        assert(bt.delete_max_key().val == 'd')
        assert(bt.delete_max_key().val == 'c')
        assert(bt.delete_max_key().val == 'b')
        assert(bt.delete_max_key().val == 'a')
        assert(bt.size == 0)
        assert(bt.delete_max_key() == nil)
        assert(bt.size == 0)
        
        rt = bt.instance_variable_get("@root")

    end
    
    def test_delete_min_key()
        bt = Btree.new()
        bt.insert(1, 'a')
        bt.insert(2, 'b')
        bt.insert(3, 'c')
        bt.insert(4, 'd')
        bt.insert(5, 'e')
        bt.insert(6, 'f')
        
        assert(bt.size == 6, "Size was not 5 but #{bt.size}")
        assert(bt.delete_min_key().val == 'a')
        assert(bt.delete_min_key().val == 'b')
        assert(bt.delete_min_key().val == 'c')
        assert(bt.delete_min_key().val == 'd')
        assert(bt.delete_min_key().val == 'e')
        assert(bt.delete_min_key().val == 'f')
        assert(bt.size == 0)
        assert(bt.delete_min_key() == nil)
        assert(bt.size == 0)
        
        rt = bt.instance_variable_get("@root")

    end
    
    def test_delete_from_root()
        bt = Btree.new()
        bt.insert(1, 'a')
        bt.insert(2, 'b')
        bt.insert(3, 'c')
        bt.insert(4, 'd')
        bt.insert(5, 'e')
        bt.insert(6, 'f')
        
        assert(bt.delete(2)=='b')
        assert(bt.delete(3)=='c')
        assert(bt.delete(1)=='a')
        assert(bt.delete(4)=='d')
            
        rt = bt.instance_variable_get("@root")
        assert(bt.size == 2)
        assert(rt.nodes.size == 0)
        assert(rt.keys.size == 2)
    end
    
    def test_list_add_remove()
        bt = Btree.new()
        
        added_items = [975, 801, 916, 648, 259, 103, 212, 230, 336, 371]

        added_items.each do |r|        
            bt.insert(r, r)
        end
        
        assert(bt.size == added_items.size)
        
        added_items.each do |k|
            prev_size = bt.size
            assert(bt.delete(k) == k)
            assert(bt.size == prev_size -1)
        end
    end
    
    def test_random_add_remove()
        bt = Btree.new()
        
        added_items = []
        
        sz = 10
        sz.times do
            r = (rand * 1000).to_i
            added_items << r
            bt.insert(r, r)
        end
        
        assert(bt.size == sz)
        
        added_items.each do |k|
            prev_size = bt.size
            assert(bt.delete(k) == k)
            assert(bt.size == prev_size -1)
        end
    end

    def test_adds()
        bt = Btree.new()
        
        bt[1] = 1
        bt[1] = 'a'
        
        assert(bt[1] == 'a')
    end
    
    def test_each()
        
        i = 0
        
        bt = Btree.new()
        bt.insert(1, 'a')
        bt.insert(2, 'b')
        bt.insert(3, 'c')
        bt.insert(4, 'd')
        bt.insert(5, 'e')
        bt.insert(6, 'f')
        
        bt.each { |k,v| i+=1 }
        
        assert(i == bt.size)
        
    end
end
