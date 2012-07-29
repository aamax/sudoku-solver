require 'pry'

class SudokuBoard
  attr_accessor :cells, :rows, :columns, :boxes
  
  def initialize
    @cells = []
    @rows = []
    @columns = []
    @boxes = []
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
      @columns[col_idx].add new_cell
      
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
        end
        (0..2).each do |n|
          @boxes[box_number].add @cells[middle + n]
        end  
        (0..2).each do |n|    
          @boxes[box_number].add @cells[bottom + n]          
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
end

class Cell
  attr_accessor :value, :possibles
  
  def initialize(value)
    @value = value
    @possibles = []
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
    
    it "should have valid rows when empty board" do      
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
      end
    end
      
    context "check columns and boxes" do
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
      end
      
    end
  end
end