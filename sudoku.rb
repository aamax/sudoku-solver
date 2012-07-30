require 'pry'

class SudokuBoard
  attr_accessor :cells, :rows, :columns, :boxes, :number_cells_changed
  
  def initialize
    @cells = []
    @rows = []
    @columns = []
    @boxes = []
    @number_cells_changed = 0
    (1..9).each do 
      @rows << SudokuSet.new
      @columns << SudokuSet.new
      @boxes << SudokuSet.new
    end
      
    row_idx = 0
    col_idx = 0
    box_idx = 0
    
    (0..80).each do |idx|
      new_cell = Cell.new(0)
      @cells << new_cell
      
      if @rows[row_idx].length == 9
        row_idx += 1 
        col_idx = 0       
      end
      @rows[row_idx].add new_cell
      new_cell.row = @rows[row_idx]
      
      @columns[col_idx].add new_cell
      new_cell.column = @columns[col_idx]
      col_idx += 1
    end
    
    (0..2).each do |col|          
      (0..2).each do |row|
        box_number = row * 3 + col            
        top = (3 * col) + (27 * row)
        middle = 9 + top
        bottom = 18 + top
        
        (0..2).each do |n|
          @boxes[box_number].add @cells[top + n]
          @cells[top + n].box = @boxes[box_number]
        end
        (0..2).each do |n|
          @boxes[box_number].add @cells[middle + n]
          @cells[middle + n].box = @boxes[box_number]
        end  
        (0..2).each do |n|    
          @boxes[box_number].add @cells[bottom + n]  
          @cells[bottom + n].box = @boxes[box_number]        
        end
      end          
    end
  end
  
  def setup(setup_array) 
    (0..8).each do |n|
      (0..8).each do |c|        
        @cells[n * 9 + c].value = setup_array[n][c]
      end
    end
  end
  
  def clear
    @cells.each do |c|
      c.value = 0
    end
  end
  
  def valid?
    @rows.each do |r|
      unless r.valid?
        return false
      end
    end
    
    @columns.each do |c|
      unless c.valid?
        return false
      end
    end
    
    @boxes.each do |b|
      unless b.valid?
        return false
      end
    end
    true
  end  
  
  def update_values
    # iterate all cells
    @cells.each do |c|
      # clear possibles for cell
      set_possibles_for_cell(c)
    end
  end
  
  def set_possibles_for_cell(c)
    c.possible_list.clear
    if c.value == 0
      (1..9).each do |n|
        found = false
        
        c.row.values.each do |v|
          if v.value ==  n
            found = true
            break
          end
        end
        
        c.column.values.each do |v|
          if v.value == n
            found = true
            break
          end
        end
        
        c.box.values.each do |v|
          if v.value == n
            found = true
            break
          end
        end
        if !found
          c.possible_list << n
        end          
      end
    end
  end
  
  def process_possibilities
    @number_cells_changed = 0
    @cells.each do |c|
      if c.possible_list.length == 1
        @number_cells_changed += 1
        c.value = c.possible_list[0]
      end
    end
  end
  
  def solved?
    @cells.each do |c|
      if c.value == 0
        return false
      end
    end
    true
  end
  
  def display
    puts ""
    @rows.each do |r|
      str = "|"
      r.values.each do |c|
        str += c.value.to_s + "|"
      end
      puts str
    end
  end

  def solve_game
    cells_changed = 0
    total_unset = 81
    number_unset = self.unset_count
    while number_unset > 0
      update_values 
      process_possibilities
      cells_changed += @number_cells_changed
      
      number_unset = self.unset_count
      if total_unset != number_unset
        total_unset = number_unset
      else
        break
      end
    end  
    
    @number_cells_changed = cells_changed  
    if total_unset > 0
      brut_force_solver
    else
      true
    end
  end
  
  def brut_force_solver
    @cells.each do |c|
      next if c.value != 0
      
      set_possibles_for_cell(c)
      c.possible_list.each do |v|
        c.value = v
        found_all = brut_force_solver
        if (found_all  == true)
          return true
        end
      end
      
      c.value = 0
      return false
    end
    true
  end
  
  def unset_count
    count = 0
    @cells.each do |c|
      if c.value == 0
        count += 1
      end
    end
    count
  end
end

class Cell
  attr_accessor :value, :row, :box, :column, :possible_list
  
  def initialize(value)  
    @value = value
    @possible_list = []
    @row = nil
    @box = nil
    @column = nil    
  end

end

class SudokuSet
  attr_accessor :values
   
  def initialize
    @values = []
  end
  
  def add(value)
    @values << value
  end
  
  def length
    @values.length
  end
  
  def valid?
    temp_array = []
    @values.each do |v|
      next if v.value == 0      
      
      if temp_array.include? v.value        
        return false
      end
      temp_array << v.value
    end
    
    true
  end
end



describe SudokuBoard do
  before :each do
    @game = SudokuBoard.new
  end
  
  context "setup the board" do
    it "should contain 81 cells" do
      @game.cells.length.should == 81
    end
    
    it "should contain 9 rows" do
      @game.rows.length.should == 9
    end
    
    it "should contain 9 columns" do
      @game.columns.length.should == 9
    end
    
    it "should contain 9 boxes" do
      @game.boxes.length.should == 9
    end
    
    context "populate cells, rows, columns, and boxes" do
      before :each do
        @master_array = []
        (0..8).each do |x|
          setup_array = []
          (0..8).each do |n|
            setup_array << (n + 1)
          end
          @master_array << setup_array          
        end
        @game.setup(@master_array)
      end
      
      it "should properly initialize the cells array" do                   
        (0..8).each do |row|
          (0..8).each do |col|
            @game.cells[row  * 9 + col].value.should == col + 1
          end
        end
      end
      
      it "should properly intialize the rows objects" do       
        @game.rows.each do |r|
          r.values.each_with_index do |cell, idx|
            cell.value.should == idx + 1
          end
        end
      end
      
      it "should properly intialize the cols objects" do        
        (0..8).each do |n|
          @game.columns[n].values.each do |col|
            col.value.should == n + 1
          end
        end
      end
      
      it "should properly initialize the box objects" do  
        @game.clear
  
        (0..2).each do |col|          
          (0..2).each do |row|
            box_number = row * 3 + col            
            top = (3 * col) + (27 * row)
            middle = 9 + top
            bottom = 18 + top
  
            (0..2).each do |n|
              @game.cells[top + n].value = box_number + 1
              @game.cells[middle + n].value = box_number + 1
              @game.cells[bottom + n].value = box_number + 1
            end
          end          
        end
  
        (0..8).each do |b|
          (0..8).each do |c|
            @game.boxes[b].values[c].value.should == b + 1
          end
        end
      end
    
      it "cells should know what row they are in" do
        @game.cells.each_with_index do |cell, index|
          row = index / 9
          cell.row.should == @game.rows[row]
        end
      end
      
      it "cells should know what column they are in" do
        @game.cells.each_with_index do |cell, index|
          column = index % 9
          cell.column.should == @game.columns[column]
        end
      end
      
      it "cells should know what box they are in" do
        @game.cells.each_with_index do |cell, index|
          box = 0
          row = index / 9
          column = index % 9
          box = 3 if row > 2 
          box = 6 if row > 5 
          box += 1 if column > 2
          box += 1 if column > 5
          cell.box.should == @game.boxes[box]
        end
      end
    end
  end
  
  context "validate the board" do
    before :each do
      @master_array = []
      (0..8).each do |x|
        setup_array = []
        (0..8).each do |n|
          setup_array << 0
        end
        @master_array << setup_array
      end
    end
    
    it "should have valid rows, columns and boxes when empty board" do      
      @game.setup(@master_array)
      
      @game.rows.each do |r|
        r.valid?.should == true
      end
      @game.columns.each do |c|
        c.valid?.should == true
      end
      @game.boxes.each do |b|
        b.valid?.should == true
      end
      @game.valid?.should == true
    end
    
    context "check rows and boxes" do
      it "should be invalid if dupes in row 0 for row 0 and box 0. columns all valid" do
        @master_array[0][0] = 9
        @master_array[0][1] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 0
          r.valid?.should == false if idx == 0
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 0
          b.valid?.should == false if idx == 0
        end    
        @game.valid?.should == false  
      end
    
      it "should be invalid if dupes in row 4 for row 4 and box 3. columns all valid" do
        @master_array[4][0] = 9
        @master_array[4][1] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 4
          r.valid?.should == false if idx == 4
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 3
          b.valid?.should == false if idx == 3
        end      
        @game.valid?.should == false  
      end
    
      it "should be invalid if dupes in row 8 for row 8 and box 6. columns all valid" do
        @master_array[8][0] = 9
        @master_array[8][1] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 8
          r.valid?.should == false if idx == 8
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 6
          b.valid?.should == false if idx == 6
        end  
        @game.valid?.should == false      
      end
      
      it "should be invalid if dupes in row 0 for row 0 and box 0. columns all valid" do
        @master_array[0][4] = 9
        @master_array[0][5] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 0
          r.valid?.should == false if idx == 0
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 1
          b.valid?.should == false if idx == 1
        end   
        @game.valid?.should == false     
      end
      
      it "should be invalid if dupes in row 4 for row 4 and box 3. columns all valid" do
        @master_array[4][4] = 9
        @master_array[4][5] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 4
          r.valid?.should == false if idx == 4
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 4
          b.valid?.should == false if idx == 4
        end   
        @game.valid?.should == false     
      end
      
      it "should be invalid if dupes in row 8 for row 8 and box 6. columns all valid" do
        @master_array[8][4] = 9
        @master_array[8][5] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 8
          r.valid?.should == false if idx == 8
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 7
          b.valid?.should == false if idx == 7
        end 
        @game.valid?.should == false       
      end
    
      it "should be invalid if dupes in row 0 for row 0 and box 0. columns all valid" do
        @master_array[0][7] = 9
        @master_array[0][8] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 0
          r.valid?.should == false if idx == 0
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 2
          b.valid?.should == false if idx == 2
        end 
        @game.valid?.should == false       
      end
    
      it "should be invalid if dupes in row 4 for row 4 and box 3. columns all valid" do
        @master_array[4][7] = 9
        @master_array[4][8] = 9
      
        @game.setup(@master_array)
      
        @game.rows.each_with_index do |r, idx|
          r.valid?.should == true unless idx == 4
          r.valid?.should == false if idx == 4
        end
        @game.columns.each_with_index do |c, idx|
          c.valid?.should == true 
        end
        @game.boxes.each_with_index do |b, idx|
          b.valid?.should == true unless idx == 5
          b.valid?.should == false if idx == 5
        end 
        @game.valid?.should == false       
      end
    end
      
    context "check columns and boxes" do
      context "boxes 0, 1, 2" do
        it "should be invalid if dupes in column 0 for column 0 and box 0. row all valid" do
          @master_array[0][0] = 9
          @master_array[1][0] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 0
            c.valid?.should == false if idx == 0
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 0
            b.valid?.should == false if idx == 0
          end     
          @game.valid?.should == false   
        end
      
        it "should be invalid if dupes in column 1 for column 1 and box 0. row all valid" do
          @master_array[0][1] = 9
          @master_array[1][1] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 1
            c.valid?.should == false if idx == 1
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 0
            b.valid?.should == false if idx == 0
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 2 for column 2 and box 0. row all valid" do
          @master_array[0][2] = 9
          @master_array[1][2] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 2
            c.valid?.should == false if idx == 2
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 0
            b.valid?.should == false if idx == 0
          end  
          @game.valid?.should == false      
        end
    
        it "should be invalid if dupes in column 3 for column 3 and box 1. row all valid" do
          @master_array[0][3] = 9
          @master_array[1][3] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 3
            c.valid?.should == false if idx == 3
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 1
            b.valid?.should == false if idx == 1
          end  
          @game.valid?.should == false      
        end
      
        it "should be invalid if dupes in column 4 for column 4 and box 1. row all valid" do
          @master_array[0][4] = 9
          @master_array[1][4] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 4
            c.valid?.should == false if idx == 4
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 1
            b.valid?.should == false if idx == 1
          end  
          @game.valid?.should == false      
        end
      
        it "should be invalid if dupes in column 5 for column 5 and box 1. row all valid" do
          @master_array[0][5] = 9
          @master_array[1][5] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 5
            c.valid?.should == false if idx == 5
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 1
            b.valid?.should == false if idx == 1
          end 
          @game.valid?.should == false       
        end
  
        it "should be invalid if dupes in column 6 for column 6 and box 2. row all valid" do
          @master_array[0][6] = 9
          @master_array[1][6] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 6
            c.valid?.should == false if idx == 6
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 2
            b.valid?.should == false if idx == 2
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 7 for column 7 and box 2. row all valid" do
          @master_array[0][7] = 9
          @master_array[1][7] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 7
            c.valid?.should == false if idx == 7
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 2
            b.valid?.should == false if idx == 2
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 8 for column 8 and box 2. row all valid" do
          @master_array[0][8] = 9
          @master_array[1][8] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 8
            c.valid?.should == false if idx == 8
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 2
            b.valid?.should == false if idx == 2
          end  
          @game.valid?.should == false      
        end
      end
  
      context "boxes 3, 4, 5" do
        it "should be invalid if dupes in column 0 for column 0 and box 3. row all valid" do
          @master_array[3][0] = 9
          @master_array[4][0] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 0
            c.valid?.should == false if idx == 0
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 3
            b.valid?.should == false if idx == 3
          end      
          @game.valid?.should == false  
        end
      
        it "should be invalid if dupes in column 1 for column 1 and box 3. row all valid" do
          @master_array[3][1] = 9
          @master_array[4][1] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 1
            c.valid?.should == false if idx == 1
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 3
            b.valid?.should == false if idx == 3
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 2 for column 2 and box 3. row all valid" do
          @master_array[3][2] = 9
          @master_array[4][2] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 2
            c.valid?.should == false if idx == 2
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 3
            b.valid?.should == false if idx == 3
          end  
          @game.valid?.should == false      
        end
    
        it "should be invalid if dupes in column 3 for column 3 and box 4. row all valid" do
          @master_array[3][3] = 9
          @master_array[4][3] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 3
            c.valid?.should == false if idx == 3
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 4
            b.valid?.should == false if idx == 4
          end  
          @game.valid?.should == false      
        end
      
        it "should be invalid if dupes in column 4 for column 4 and box 4. row all valid" do
          @master_array[3][4] = 9
          @master_array[4][4] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 4
            c.valid?.should == false if idx == 4
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 4
            b.valid?.should == false if idx == 4
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 5 for column 5 and box 4. row all valid" do
          @master_array[3][5] = 9
          @master_array[4][5] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 5
            c.valid?.should == false if idx == 5
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 4
            b.valid?.should == false if idx == 4
          end   
          @game.valid?.should == false     
        end
  
        it "should be invalid if dupes in column 6 for column 6 and box 5. row all valid" do
          @master_array[3][6] = 9
          @master_array[4][6] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 6
            c.valid?.should == false if idx == 6
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 5
            b.valid?.should == false if idx == 5
          end 
          @game.valid?.should == false       
        end
      
        it "should be invalid if dupes in column 7 for column 7 and box 5. row all valid" do
          @master_array[3][7] = 9
          @master_array[4][7] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 7
            c.valid?.should == false if idx == 7
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 5
            b.valid?.should == false if idx == 5
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 8 for column 8 and box 5. row all valid" do
          @master_array[3][8] = 9
          @master_array[4][8] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 8
            c.valid?.should == false if idx == 8
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 5
            b.valid?.should == false if idx == 5
          end  
          @game.valid?.should == false      
        end
      end
     
      context "boxes 6, 7, 8" do
        it "should be invalid if dupes in column 0 for column 0 and box 6. row all valid" do
          @master_array[6][0] = 9
          @master_array[7][0] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 0
            c.valid?.should == false if idx == 0
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 6
            b.valid?.should == false if idx == 6
          end      
          @game.valid?.should == false  
        end
      
        it "should be invalid if dupes in column 1 for column 1 and box 6. row all valid" do
          @master_array[6][1] = 9
          @master_array[7][1] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 1
            c.valid?.should == false if idx == 1
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 6
            b.valid?.should == false if idx == 6
          end      
          @game.valid?.should == false  
        end
      
        it "should be invalid if dupes in column 2 for column 2 and box 6. row all valid" do
          @master_array[7][2] = 9
          @master_array[8][2] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 2
            c.valid?.should == false if idx == 2
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 6
            b.valid?.should == false if idx == 6
          end   
          @game.valid?.should == false     
        end
    
        it "should be invalid if dupes in column 3 for column 3 and box 7. row all valid" do
          @master_array[6][3] = 9
          @master_array[8][3] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 3
            c.valid?.should == false if idx == 3
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 7
            b.valid?.should == false if idx == 7
          end   
          @game.valid?.should == false     
        end
      
        it "should be invalid if dupes in column 4 for column 4 and box 7. row all valid" do
          @master_array[7][4] = 9
          @master_array[6][4] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 4
            c.valid?.should == false if idx == 4
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 7
            b.valid?.should == false if idx == 7
          end    
          @game.valid?.should == false    
        end
      
        it "should be invalid if dupes in column 5 for column 5 and box 7. row all valid" do
          @master_array[8][5] = 9
          @master_array[7][5] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 5
            c.valid?.should == false if idx == 5
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 7
            b.valid?.should == false if idx == 7
          end  
          @game.valid?.should == false      
        end
  
        it "should be invalid if dupes in column 6 for column 6 and box 8. row all valid" do
          @master_array[8][6] = 9
          @master_array[7][6] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 6
            c.valid?.should == false if idx == 6
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 8
            b.valid?.should == false if idx == 8
          end  
          @game.valid?.should == false      
        end
      
        it "should be invalid if dupes in column 7 for column 7 and box 8. row all valid" do
          @master_array[7][7] = 9
          @master_array[6][7] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 7
            c.valid?.should == false if idx == 7
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 8
            b.valid?.should == false if idx == 8
          end  
          @game.valid?.should == false      
        end
      
        it "should be invalid if dupes in column 8 for column 8 and box 8. row all valid" do
          @master_array[7][8] = 9
          @master_array[8][8] = 9
      
          @game.setup(@master_array)
      
          @game.columns.each_with_index do |c, idx|
            c.valid?.should == true unless idx == 8
            c.valid?.should == false if idx == 8
          end
          @game.rows.each_with_index do |r, idx|
            r.valid?.should == true 
          end
          @game.boxes.each_with_index do |b, idx|
            b.valid?.should == true unless idx == 8
            b.valid?.should == false if idx == 8
          end   
          @game.valid?.should == false     
        end
      end
  
    end
  end

  context "solve the board" do
    context "possibilities testing" do
      it "should show all possabilities for a cell with no neighbors" do
        @game.update_values
        @game.cells.each do |c|
          c.possible_list.should == [1,2,3,4,5,6,7,8,9]
        end
      end
    
      it "should show valid possibles for a cell with a single set value" do
        (1..9).each do |n|
          @game.cells[0].value = n
          @game.update_values
          result_list = [1,2,3,4,5,6,7,8,9].delete_if { |v| v == n }
          @game.cells[1].possible_list.should == result_list
        end
      end
      
      it "should show valid possibilities for a row with one empty value" do
        row = @game.rows[0]
        (0..7).each do |n|
          row.values[n].value = n + 1
        end
        
        @game.update_values        
        @game.rows[0].values[8].possible_list.should == [9]
      end
      
      it "should show valid possibilities for a column with one empty value" do
        col = @game.columns[0]
        (0..7).each do |n|
          col.values[n].value = n + 1
        end
        
        @game.update_values        
        @game.columns[0].values[8].possible_list.should == [9]
      end
      
      it "should show valid possibilities for a box with one empty value" do
        box = @game.boxes[0]
        (0..7).each do |n|
          box.values[n].value = n + 1
        end
        
        @game.update_values        
        @game.boxes[0].values[8].possible_list.should == [9]
      end
    
      it "should set the value for cells that only have one possibility in a row" do
        row = @game.rows[0]
        (0..7).each do |n|
          row.values[n].value = n + 1
        end
        
        @game.update_values 
        @game.process_possibilities       
        @game.rows[0].values[8].value.should == 9
        @game.number_cells_changed.should == 1
      end
      
      it "should set the value for cells that only have one possibility in a column" do
        column = @game.columns[0]
        (0..7).each do |n|
          column.values[n].value = n + 1
        end
        
        @game.update_values 
        @game.process_possibilities       
        @game.columns[0].values[8].value.should == 9
        @game.number_cells_changed.should == 1
      end
  
      it "should set the value for cells that only have one possibility in a box" do
        box = @game.boxes[0]
        (0..7).each do |n|
          box.values[n].value = n + 1
        end
        
        @game.update_values 
        @game.process_possibilities       
        @game.boxes[0].values[8].value.should == 9
        @game.number_cells_changed.should == 1
      end
    end  
  
    it "should solve the puzzle if there is only a single value to fill in" do
      setup_array = [
        [0,1,2,3,4,5,6,7,8],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9],
        [1,2,3,4,5,6,7,8,9]
        ]
        
        @game.setup(setup_array)
        @game.update_values 
        @game.process_possibilities
        @game.number_cells_changed.should == 1
        @game.cells[0].value.should == 9
        @game.solved?.should == true
    end
    
    it "should solve the puzzle if it can resolve in 2 passes" do
      setup_array = [[0,0,0,0,0,0,0,0,0],
                      [9,7,4,5,3,6,8,0,1],
                      [1,5,8,7,2,9,0,6,3],
                      [2,4,5,1,9,0,7,3,6],
                      [7,3,1,4,0,5,2,9,8],
                      [8,6,9,0,7,2,1,5,4],
                      [5,8,0,9,4,3,6,1,7],
                      [4,0,6,2,5,7,3,8,9],
                      [0,9,7,6,8,1,5,4,2]]
        
        @game.setup(setup_array)
        @game.update_values 
        @game.process_possibilities
        @game.update_values 
        @game.process_possibilities
        
        @game.cells[0].value.should == 6
        @game.cells[1].value.should == 2
        @game.cells[2].value.should == 3
        @game.cells[3].value.should == 8
        @game.cells[4].value.should == 1
        @game.cells[5].value.should == 4
        @game.cells[6].value.should == 9
        @game.cells[7].value.should == 7
        @game.cells[8].value.should == 5
        @game.rows[8].values[0].value.should == 3
        @game.rows[7].values[1].value.should == 1
        @game.rows[6].values[2].value.should == 2
        @game.rows[5].values[3].value.should == 3
        @game.rows[4].values[4].value.should == 6
        @game.rows[3].values[5].value.should == 8
        @game.rows[2].values[6].value.should == 4
        @game.rows[1].values[7].value.should == 2
        
        @game.solved?.should == true
    end  
    
    it "should solve the game if it can do it by resolving in 2 passes" do
      setup_array = [[0,0,0,0,0,0,0,0,0],
                      [9,7,4,5,3,6,8,0,1],
                      [1,5,8,7,2,9,0,6,3],
                      [2,4,5,1,9,0,7,3,6],
                      [7,3,1,4,0,5,2,9,8],
                      [8,6,9,0,7,2,1,5,4],
                      [5,8,0,9,4,3,6,1,7],
                      [4,0,6,2,5,7,3,8,9],
                      [0,9,7,6,8,1,5,4,2]]
      
        @game.setup(setup_array)
        @game.solve_game.should == true
      
        @game.cells[0].value.should == 6
        @game.cells[1].value.should == 2
        @game.cells[2].value.should == 3
        @game.cells[3].value.should == 8
        @game.cells[4].value.should == 1
        @game.cells[5].value.should == 4
        @game.cells[6].value.should == 9
        @game.cells[7].value.should == 7
        @game.cells[8].value.should == 5
        @game.rows[8].values[0].value.should == 3
        @game.rows[7].values[1].value.should == 1
        @game.rows[6].values[2].value.should == 2
        @game.rows[5].values[3].value.should == 3
        @game.rows[4].values[4].value.should == 6
        @game.rows[3].values[5].value.should == 8
        @game.rows[2].values[6].value.should == 4
        @game.rows[1].values[7].value.should == 2
      
        @game.solved?.should == true
      end  
      
      it "should solve another game" do
        setup_array =  [[9,0,0,0,3,5,1,6,0],
                        [5,3,0,0,0,0,0,9,0],
                        [0,0,0,0,0,0,5,0,0],
                        [8,7,0,0,0,6,0,0,2],
                        [0,0,5,0,2,0,3,0,0],
                        [2,0,0,8,0,0,0,1,5],
                        [0,5,6,0,0,0,0,0,0],
                        [0,4,0,0,0,0,0,7,0],
                        [0,2,9,1,6,0,0,5,4]]

          @game.setup(setup_array)
          val = @game.solve_game
          val.should == true
      end     
      
      it "should solve a simple game" do
        setup_array =  [[0,0,0,0,0,9,7,6,0],
                        [0,7,0,4,0,0,1,2,0],
                        [0,0,4,0,0,0,0,0,0],
                        [0,2,7,3,6,0,8,9,0],
                        [0,0,0,2,0,7,0,0,0],
                        [0,4,3,0,9,5,2,1,0],
                        [0,0,0,0,0,0,5,0,0],
                        [0,6,5,0,0,3,0,4,0],
                        [0,3,9,7,0,0,0,0,0]]

          @game.setup(setup_array)
          val = @game.solve_game
          val.should == true
      end        
         
  end
end