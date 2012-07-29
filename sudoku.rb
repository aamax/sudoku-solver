class SudokuBoard
  attr_accessor :cells
  
  def initialize
    @cells = []
    81.times do
      @cells << Cell.new
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