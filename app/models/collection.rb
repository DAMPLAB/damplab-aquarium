class Collection < Item

  # CLASS METHODS ###################################################################

  def self.spread samples, name, rows, cols

    samples_per_collection = rows * cols
    num_collections = ( samples.length / samples_per_collection.to_f ).ceil
    s = 0

    collections = (1..num_collections).collect do |i| 

      c = self.new_collection name, rows, cols
      m = c.get_matrix
      (0..rows-1).each do |r|
        (0..cols-1).each do |c|
          if s < samples.length
            m[r][c] = samples[s].id
          end
          s += 1
        end
      end
      c.set_matrix m # note, also saves c
      c

    end

    return collections

  end

  # METHODS #########################################################################

  def self.new_collection name, r, c

    o = ObjectType.find_by_name(name)
    raise "Could not find object type named '#{name}'." unless o

    i = Collection.new
    i.object_type_id = o.id
    i.apportion r,c
    i.location = o.location_wizard
    i.quantity = 1
    i.inuse = 0
    i.save
    i

  end

  def apportion r, c
    self.data =  { matrix: (Array.new(r,Array.new(c,-1))) }.to_json
  end

  def associate sample_matrix

    m = self.get_data[:matrix]

    (0..sample_matrix.length-1).each do |r|
      (0..sample_matrix[r].length-1).each do |c|
        if sample_matrix[r][c].class == Sample
          m[r][c] = sample_matrix[r][c].id
        else
          m[r][c] = sample_matrix[r][c]
        end
      end
    end

    self.data = { matrix: m }.to_json
    self.save

  end

  def set_matrix m
    self.associate m
  end

  def get_matrix
    d = self.get_data
    d[:matrix]
  end

  def dimensions
    m = self.get_matrix
    [ m.length, m[0].length ]
  end

  def num_samples

    m = self.get_matrix
    s = 0

    (0..m.length-1).each do |r|
      (0..m[r].length-1).each do |c|
        if m[r][c] != -1
          s += 1
        end
      end
    end

    s

  end

  def non_empty

    m = self.get_matrix
    max = [0,0]

    (0..m.length-1).each do |r|
      (0..m[r].length-1).each do |c|
        if m[r][c] != -1
          max = [r,c]
        end
      end
    end

    if m.length > 1 
      "1,1 - #{max[0]+1}, #{max[1]+1}"
    else
      "1 - #{max[1]+1}"
    end

  end

end

