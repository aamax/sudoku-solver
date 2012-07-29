class SudokuBoard
  attr_accessor :cells, :rows, :columns, :boxes
  
  def initialize
    @cells = []
    @rows = [[]]    
    @boxes = [[]]
    @columns = [[]]
    row_idx = 0
    col_idx = 0
    box_idx = 0
    
    (0..80).each do |idx|
      new_cell = Cell.new
      @cells << new_cell
      
      if @rows[row_idx].length == 9
        @rows << []
        row_idx += 1        
      end
      @rows[row_idx] << new_cell
      
      if @columns[col_idx].length == 9
        @columns << []
        col_idx += 1        
      end
      @columns[col_idx] << new_cell
      
      if @boxes[box_idx].length == 9
        @boxes << []
        box_idx += 1        
      end
      @boxes[box_idx] << new_cell
    end    
  end
end

class Cell
  
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
  end
  
  
end