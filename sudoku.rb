require 'pry'

class SudokuBoard
  attr_accessor :cells, :rows, :columns, :boxes
  
  def initialize
    @cells = []
    @rows = [SudokuSet.new]    
    @boxes = [SudokuSet.new]
    @columns = [SudokuSet.new]
    row_idx = 0
    col_idx = 0
    box_idx = 0
    
    (0..80).each do |idx|
      new_cell = Cell.new(0)
      @cells << new_cell
      
      if @rows[row_idx].length == 9
        @rows << SudokuSet.new
        row_idx += 1        
      end
      @rows[row_idx].add new_cell
      
      if @columns[col_idx].length == 9
        @columns << SudokuSet.new
        col_idx += 1        
      end
      @columns[col_idx].add new_cell
      
      if @boxes[box_idx].length == 9
        @boxes << SudokuSet.new
        box_idx += 1        
      end
      @boxes[box_idx].add new_cell
    end    
  end
  
  def setup(setup_array)
    (0..8).each do |n|
      (0..8).each do |c|
        @cells[n * 9 + c].value = setup_array[n][c]
      end
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
    
    it "should properly initialize" do      
      master_array = []
      (0..8).each do |x|
        setup_array = []
        (0..8).each do |n|
          setup_array << (n + 1)
        end
        master_array << setup_array
      end
      
      @game.setup(master_array)
      (0..8).each do |row|
        (0..8).each do |col|
          @game.cells[row  * 9 + col].value.should == col + 1
        end
      end
    end
  end
  
  context "solve the board" do
    before :each do
      @master_array = []
      (0..8).each do |x|
        setup_array = []
        (0..8).each do |n|
          setup_array << (n + 1)
        end
        @master_array << setup_array
      end
    end
    
    it "should have valid rows when no duplicates" do      
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
    
    it "should indicate invalid if there are duplicates in rows, columns, or boxes" do
      @master_array[0][0] = 9
      
      @game.setup(@master_array)
      
      @game.rows.each_with_index do |r, idx|
        r.valid?.should == true unless idx == 0
        r.valid?.should == false if idx == 0
      end
      @game.columns.each_with_index do |c, idx|
        c.valid?.should == true unless idx == 0
        c.valid?.should == false if idx == 0
      end
      @game.boxes.each_with_index do |b, idx|
        b.valid?.should == true unless idx == 0
        b.valid?.should == false if idx == 0
      end
      
    end
 
    it "cells should know possible legal values" do
      
    end
  end
  
end