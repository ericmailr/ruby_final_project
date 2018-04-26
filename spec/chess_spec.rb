
#spec/chess_spec.rb

require "chess"

 describe Chess do

	describe Player do
		
		describe ".checkmate" do

		#fails	
			context "given king surrounded by rooks" do
								
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns true" do
					board.board[0][0].update_piece(Piece.new("king","w"))
					board.board[1][0].update_piece(Piece.new("queen","b"))
					board.board[0][1].update_piece(Piece.new("queen","b"))
					
					expect(board.checkmate?("w")).to eql(true)
				end
			end
			
			context "given king in check stuck in corner, rook block" do 
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
			
				it "returns false" do
					board.board[0][0].update_piece(Piece.new("king","w"))
					board.board[1][0].update_piece(Piece.new("rook","w"))
					board.board[0][1].update_piece(Piece.new("rook","w"))
					board.board[2][3].update_piece(Piece.new("queen","b"))
				
			
					expect(board.checkmate?("w")).to eql(false)
				end
			end
		
			context "given king in check directly next to one queen" do 
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
			
				it "returns false" do
					board.board[0][0].update_piece(Piece.new("king","w"))
					board.board[1][0].update_piece(Piece.new("queen","b"))
			
					expect(board.checkmate?("w")).to eql(false)
				end
			end
		

			
		end
	
		describe ".move" do

			context "move that corners king" do
								
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns 'Checkmate! Black wins'" do
					board.board[0][0].update_piece(Piece.new("king","w"))
					board.board[3][1].update_piece(Piece.new("rook","b"))
					board.board[4][1].update_piece(Piece.new("rook","b"))
					expect(p2.move("41","40")).to eql("Checkmate! Black wins!")
				end
			end

			context "try to move opponent piece" do
								
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns Error: You don't have a piece there" do
					board.board[0][0].update_piece(Piece.new("king","w"))
					board.board[4][1].update_piece(Piece.new("rook","b"))
					expect(p1.move("41","40")).to eql("Error: You don't have a piece there.")
				end
			end
			
		end
	end
	
	describe Board do
		describe ".in_check?" do
			context "move that corners king" do
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns true" do
					board.board[0][0].update_piece(Piece.new("king","b"))
					board.board[3][1].update_piece(Piece.new("queen","w"))
					board.board[4][0].update_piece(Piece.new("queen","w"))
				expect(board.in_check?("b")).to eql(true)	
				end	
			end
			context "queen 10, enemy king 01" do
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns true" do
					board.board[0][1].update_piece(Piece.new("king","b"))
					board.board[1][0].update_piece(Piece.new("queen","w"))
				expect(board.in_check?("b")).to eql(true)	
				end	
			end

		end
		describe ".get_moves_from_space" do
			context "queen surrounded by enemy pawns" do
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns array of size 8" do
					board.board[3][3].update_piece(Piece.new("queen","b"))
					board.board[3][4].update_piece(Piece.new("pawn","w"))
					board.board[4][3].update_piece(Piece.new("pawn","w"))
					board.board[2][3].update_piece(Piece.new("pawn","w"))
					board.board[3][2].update_piece(Piece.new("pawn","w"))
					board.board[2][4].update_piece(Piece.new("pawn","w"))
					board.board[4][2].update_piece(Piece.new("pawn","w"))
					board.board[4][4].update_piece(Piece.new("pawn","w"))
					board.board[2][2].update_piece(Piece.new("pawn","w"))
						
					expect(board.get_moves_from_space(board.board[3][3]).size).to eql(8)
				end
				
		end
			context "bishop surrounded by enemy pawns" do
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns array of size 8" do
					board.board[3][3].update_piece(Piece.new("bishop","b"))
					board.board[3][4].update_piece(Piece.new("pawn","w"))
					board.board[4][3].update_piece(Piece.new("pawn","w"))
					board.board[2][3].update_piece(Piece.new("pawn","w"))
					board.board[3][2].update_piece(Piece.new("pawn","w"))
					board.board[2][4].update_piece(Piece.new("pawn","w"))
					board.board[4][2].update_piece(Piece.new("pawn","w"))
					board.board[4][4].update_piece(Piece.new("pawn","w"))
					board.board[2][2].update_piece(Piece.new("pawn","w"))
						
					expect(board.get_moves_from_space(board.board[3][3]).size).to eql(4)
				end
				
		end
			context "pawns at start and not at start move 2 spaces forward" do
				let(:board) { Board.new(true) }
				let(:p1) {Player.new("w",board)}
				let(:p2) {Player.new("b",board)}
				
				it "returns success from start, error from non-start" do
					board.board[6][1].update_piece(Piece.new("pawn","w"))
					board.board[2][1].update_piece(Piece.new("pawn","w"))
						
					expect(board.get_moves_from_space(board.board[6][1]).include?(board.board[4][1])).to eql(true)
					expect(board.get_moves_from_space(board.board[2][1]).include?(board.board[0][1])).to eql(false)
				end
				
		end



		end
	end
 end
