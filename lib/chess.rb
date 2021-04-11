require "yaml"

class Board
	def initialize(test=false)
		@board = [[], [], [], [], [], [], [], []]
		#populate board with spaces
		@board.each_with_index do |row,index|
			8.times do |col|
				row << Space.new(nil,index,col)
			end
		end
		@game_over = false
		@escape_check_move = nil
		addPieces(test)	
	end	

	def board
		@board
	end

	def game_over?
		return @game_over
	end

	def escape_check_move
		return @escape_check_move
	end
	
	def addPieces(test)
		if test
			@board[7][3].update_piece(Piece.new("queen","w","\u{265B} "))
			@board[0][3].update_piece(Piece.new("queen","b","\u{2655} "))
			@board[6][0].update_piece(Piece.new("pawn","b", "\u{2659} "))
		else
			#add Pawns:
			8.times do |i|
				@board[6][i].update_piece Piece.new("pawn","w","\u{265F} ")
				@board[1][i].update_piece Piece.new("pawn","b", "\u{2659} ")
			end

			#add everything else	
			@board[7][0].update_piece(Piece.new("rook","w","\u{265C} "))
			@board[7][1].update_piece(Piece.new("knight","w","\u{265E} "))
			@board[7][2].update_piece(Piece.new("bishop","w","\u{265D} "))
			@board[7][3].update_piece(Piece.new("queen","w","\u{265B} "))
			@board[7][4].update_piece(Piece.new("king","w","\u{265A} "))
			@board[7][5].update_piece(Piece.new("bishop","w","\u{265D} "))
			@board[7][6].update_piece(Piece.new("knight","w","\u{265E} "))
			@board[7][7].update_piece(Piece.new("rook","w","\u{265C} "))
			
			@board[0][0].update_piece(Piece.new("rook","b","\u{2656} "))
			@board[0][1].update_piece(Piece.new("knight","b","\u{2658} "))
			@board[0][2].update_piece(Piece.new("bishop","b","\u{2657} "))
			@board[0][3].update_piece(Piece.new("queen","b","\u{2655} "))
			@board[0][4].update_piece(Piece.new("king","b","\u{2654} "))
			@board[0][5].update_piece(Piece.new("bishop","b","\u{2657} "))
			@board[0][6].update_piece(Piece.new("knight","b","\u{2658} "))
			@board[0][7].update_piece(Piece.new("rook","b","\u{2656} "))
		end
	end

	def spaces_of_pieces_on_board(color)
		spaces_of_pieces = []
		@board.each do |row|
			row.each do |space|
				spaces_of_pieces << space if @board[space.row][space.col].piece != nil && @board[space.row][space.col].piece.color == color
			end
		end
		return spaces_of_pieces.uniq
	end
	
	def in_check?(color)
		color == "w" ? opponent_color = "b" : opponent_color = "w"
		opponent_spaces = spaces_of_pieces_on_board(opponent_color)
		king_space = space_of_king(color)
		opponent_spaces.each do |space|
			space_moves = get_moves_from_space(space)
			return true if space_moves.include?(king_space)
		end
		return false
	end

	def checkmate?(color)
		color == "w" ? opponent_color = "b" : opponent_color = "w"
		spaces = spaces_of_pieces_on_board(color)
		spaces.each do |space|
			space_piece = space.piece
			temp_targets = get_moves_from_space(space)
			temp_targets.each do |target|
				#move piece to target
				target_piece = target.piece
				@board[target.row][target.col].update_piece(space_piece)
				@board[space.row][space.col].update_piece(nil)
				if in_check?(color) == false
					#not checkmate, send move to ai
					@escape_check_move = [space, target]
					#move pieces back
					@board[space.row][space.col].update_piece(space_piece)
					@board[target.row][target.col].update_piece(target_piece)
					return false
				else
					#move pieces back (still in check)
					@board[space.row][space.col].update_piece(space_piece)
					@board[target.row][target.col].update_piece(target_piece)
				end
			end
		end	
		@game_over = true
		return true
	end

	def space_of_king(color)
		@board.each do |row|
			row.each do |space|
				if space.piece != nil && space.piece.name == "king"
					return space if space.piece.color == color
				end
			end
		end
		return "Error: no king found."
	end

	def get_moves_from_space(space)
		return nil if space.piece == nil
		piece = space.piece
		moves = []
		temp_space = space
		color = space.piece.color
		if piece.name == "pawn"
				temp_space = up(space, color)
				if temp_space != nil
					if temp_space.piece == nil
						moves << temp_space
						if (color == "w" && space.row == 6) || (color == "b" && space.row == 1)
							moves << up(temp_space, color) if up(temp_space, color) != nil && up(temp_space, color).piece == nil
						end
					end
					moves << right(temp_space, color) if right(temp_space, color) != nil && right(temp_space, color).piece != nil && right(temp_space, color).piece.color != color
					moves << left(temp_space, color) if left(temp_space, color) != nil && left(temp_space, color).piece != nil && left(temp_space, color).piece.color != color	
				end
		end
		if piece.name == "rook" || piece.name == "queen"
				#up
				temp_space = up(space, color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = up(temp_space, color)
				end
				moves << temp_space if temp_space != nil && temp_space.piece.color != color

				#down
				temp_space = down(space, color)
				
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = down(temp_space, color)
				end
				moves << temp_space if temp_space != nil && temp_space.piece.color != color

				#right
				temp_space = right(space, color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = right(temp_space, color)
				end
				moves << temp_space if temp_space != nil && temp_space.piece.color != color
#left	
				temp_space = left(space, color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = left(temp_space, color)
				end
				moves << temp_space if temp_space != nil && temp_space.piece.color != color

		end
		if piece.name == "knight"		
				temp_space = right(up(up(space, color), color), color) 
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = left(up(up(space, color), color), color) 
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = right(down(down(space, color), color), color) 
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = left(down(down(space, color), color), color) 
				moves << temp_space if target_space_valid?(temp_space, color)

				temp_space = down(left(left(space, color), color), color)
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = up(left(left(space, color), color), color)
				moves << temp_space if target_space_valid?(temp_space, color)

				temp_space = down(right(right(space, color), color), color)
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = up(right(right(space, color), color), color)
				moves << temp_space if target_space_valid?(temp_space, color)
		end
		if piece.name == "bishop" || piece.name == "queen"
				temp_space = right(up(space, color), color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = right(up(temp_space, color), color)
				end
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = left(up(space, color), color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = left(up(temp_space, color), color)
				end
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = right(down(space, color), color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = right(down(temp_space, color), color)
				end
				moves << temp_space if target_space_valid?(temp_space, color)
				
				temp_space = left(down(space, color), color)
				while temp_space != nil && temp_space.piece == nil
					moves << temp_space
					temp_space = left(down(temp_space, color), color)
				end
				moves << temp_space if target_space_valid?(temp_space, color)
		end
		if piece.name == "king"
			moves << up(space, color) if target_space_valid?(up(space, color), color)	
			moves << down(space, color) if target_space_valid?(down(space, color), color)
			moves << left(space, color) if target_space_valid?(left(space, color), color)
			moves << right(space, color) if target_space_valid?(right(space, color), color)
			
			moves << up(left(space, color), color) if target_space_valid?(up(left(space, color), color), color)
			moves << up(right(space, color), color) if target_space_valid?(up(right(space, color), color), color)
			moves << down(left(space, color), color) if target_space_valid?(down(left(space, color), color), color)
			moves << down(right(space, color), color) if target_space_valid?(down(right(space, color), color), color)
		end
		moves = moves.uniq
		moves.delete(space) if moves.include?(space)
		return moves
	end

	def target_space_valid?(target_space, color)
		return false if target_space == nil
		return false if target_space.piece != nil && target_space.piece.color == color
		return true
	end
	
	def space(space)
		return @board[space.row][space.col]
	end

	def up(space, color)
		return @board[space.row - 1][space.col] if space != nil && space.row - 1 >= 0 && color == "w"
		return @board[space.row + 1][space.col] if space != nil && space.row + 1 <= 7 && color == "b"
		return nil
	end
	
	def down(space, color)
		return @board[space.row + 1][space.col] if space != nil && space.row + 1 <= 7 && color == "w"
		return @board[space.row - 1][space.col] if space != nil && space.row - 1 >= 0 && color == "b"
		return nil
	end
	
	def left(space, color)
		return @board[space.row][space.col - 1] if space != nil && space.col - 1 >= 0 && color == "w"
		return @board[space.row][space.col + 1] if space != nil && space.col + 1 <= 7 && color == "b"
		return nil
	end

	def right(space, color)
		return @board[space.row][space.col + 1] if space != nil && space.col + 1 <= 7 && color == "w"
		return @board[space.row][space.col - 1] if space != nil && space.col - 1 >= 0 && color == "b"
		return nil
	end

	def print_board(color)
		print color == "w" ? "    0    1    2    3    4    5    6    7   \n" : "    7    6    5    4    3    2    1    0   \n"
		print "  -----------------------------------------\n"
		if color == "w"
			@board.each do |row|
				print "#{row[0].row} "
				row.each do |space|
					print space.piece==nil ? "|    " : "| #{space.piece.unicode} " 
				end
				print "|\n  -----------------------------------------\n"
			end
		elsif color == "b"
			@board.reverse_each do |row|
				print "#{row[0].row} "
				row.reverse_each do |space|
					print space.piece==nil ? "|    " : "| #{space.piece.unicode} " 
				end
				print "|\n  -----------------------------------------\n"
			end
		end
	end
end	

class Space
	def initialize(piece=nil, row, col)
		@piece = piece
		@row = row
		@col = col
		@space_number = (row.to_s << col.to_s)
	end
	
	def piece
		@piece
	end

	def space_number
		@space_number
	end

	def row 
		@row
	end

	def col
		@col
	end

	def update_piece(piece)
		@piece = piece
	end
	
	def print_info
		puts "piece: #{@piece==nil ? "nil" : @piece.name}, color: #{@piece==nil ? "nil" : @piece.color}, row: #{@row}, col: #{@col}"
	end

end

class Piece
	def initialize(name,color,unicode=nil)
		@name = name
		@color = color
		@unicode = unicode
	end
	
	def unicode
		@unicode
	end	
	def name
		@name
	end

	def color
		@color
	end
	
	def print_info
		puts "name: #{@name}, color: #{@color}"
	end
end

class Player
	def initialize(color, board)
		@color = color
		@board = board
		@captured_pieces = []
		@opponent = nil
	end
	
	def color
		@color
	end
	
	def set_opponent(player)
		@opponent = player
	end

	def get_opponent(player)
		@opponent
	end

	def opponent_color
		return @color == "w" ? "b" : "w"
	end

	def board_array
		@board.board
	end

	def move(curr_space, target_space)
		curr_row = curr_space[0].to_i if curr_space[0] =~ /\d/
		curr_col = curr_space[1].to_i if curr_space[1] =~ /\d/
		target_row = target_space[0].to_i if target_space[0] =~ /\d/
		target_col = target_space[1].to_i if target_space[1] =~ /\d/

		(0..7) === curr_row && (0..7) === curr_col ? curr_space = board_array[curr_space[0].to_i][curr_space[1].to_i] : curr_space = nil 
		(0..7) === target_row && (0..7) === target_col ? target_space = board_array[target_space[0].to_i][target_space[1].to_i] : target_space = nil 

		
		ret = nil
		if curr_space == nil || curr_space.piece == nil || curr_space.piece.color != @color
			ret = "Error: You don't have a piece there."
		elsif target_space == nil
			ret = "Error: That spot ain't on the board, fella"
		elsif target_space.row < 0 || target_space.row > 7 || target_space.col < 0 || target_space.col > 7
			ret = "Error: You can't move there!"
		elsif target_space.piece != nil && target_space.piece.color == @color
			ret = "Error: Suicide is not an option (target space holds you own piece). Try again."
		elsif @board.get_moves_from_space(curr_space).include?(target_space)
			#add target to captured_pieces if it has a piece
			@captured_pieces << board_array[target_space.row][target_space.col].piece if board_array[target_space.row][target_space.col].piece != nil
			#update target space to curr_space's piece
			board_array[target_space.row][target_space.col].update_piece(board_array[curr_space.row][curr_space.col].piece)
			#update curr_space's piece to nil
			board_array[curr_space.row][curr_space.col].update_piece(nil)

			if @board.in_check?(@color)
				#return pieces to their positions
				board_array[curr_space.row][curr_space.col].update_piece(board_array[target_space.row][target_space.col].piece)
				board_array[target_space.row][target_space.col].update_piece(@captured_pieces.pop)
				ret = "Error: Your King is exposed."
			elsif @board.in_check?(opponent_color)
				if @board.checkmate?(opponent_color)
					ret = "Checkmate! #{@color == "w" ? "White" : "Black"} wins!"
				else
					ret = "#{target_space.piece.name} moved from #{curr_space.row}#{curr_space.col} to #{target_space.row}#{target_space.col}. CHECK!"
				end
			else
				ret = "#{target_space.piece.name} moved from #{curr_space.row}#{curr_space.col} to #{target_space.row}#{target_space.col}."
			if target_space.piece.name == "pawn" && [0,7].include?(target_space.row)
				upgrade_pawn(target_space)
			end
		end
		else
			ret = "Error: Illegal move. Try again."
		end
		return ret
	end
	
	def upgrade_pawn(pawn_space)
		puts "Player #{@color == "w" ? "White" : "Black"}, enter the name of the piece you'd like to upgrade your pawn to."
		upgraded = false
		while !upgraded
			input = gets.chomp.downcase
			@opponent.get_captured_pieces.each do |piece|
				if piece.name == input
					board_array[pawn_space.row][pawn_space.col].update_piece(piece)
					@opponent.lose_captured_piece(piece)
					upgraded = true
					break
				end
			end
			break if upgraded
			puts "You can't upgrade to that piece. Try again."
		end
		@board.print_board(@color)
	end
	
	def get_captured_pieces
		return @captured_pieces
	end	

	def lose_captured_piece(piece)
		@captured_pieces.delete(piece)
	end
	
	def print_captured_pieces
		@captured_pieces.each do |piece|
			print " #{piece.unicode}"
		end
	end
end

class Chess

	def initialize
		@board = Board.new(false)
		@player_white = Player.new("w", @board)
		@player_black = Player.new("b", @board)
		@turn = nil
		@mode = nil
	end
	
	def get_move(player)
		puts "#{player.color == "w" ? "\nWhite" : "\nBlack"}'s turn. Enter move. \t\t\tOptions: 'save' 'quit'"
			input = gets.chomp.split(' ')
			if input[0] == "quit"
				new_chess = Chess.new
				new_chess.menu	
			elsif input[0] == "save"
				@turn = player.color
				save_file = File.open("saved_game.yml", "w")	
				save_file.write(self.to_yaml)
				save_file.close
				puts "\nGame saved!"
				get_move(player)				
			elsif input.size != 2
				puts "Bad input. Enter piece coordinate (row x col) and target coordinate separated by a space (e.g. '60 50')."
				get_move(player)
			else
				print_move_result = true
				move_result = player.move(input[0],input[1])
				if move_result[0..4] == "Error"
					print_move_result = false
					puts move_result
					move_result = get_move(player)
				end
				
				return move_result
			end
	end
	
	def ai_move(board, ai)
		space = @board.spaces_of_pieces_on_board(ai.color).sample 
		while @board.get_moves_from_space(space).size == 0
			space = @board.spaces_of_pieces_on_board(ai.color).sample
		end
		target = @board.get_moves_from_space(space).sample
		move_result = ai.move(space.space_number.to_s, target.space_number.to_s)	
		new_move = [space, target, move_result]
		return new_move 
	end

	def play_friend
		while @board.game_over? == false
			if @turn == "b"
				turn(@player_black)
				@turn = nil 
				break if @board.game_over?
			end
			turn(@player_white)
			break if @board.game_over?
			turn(@player_black)
		end
	end

	def turn(player)
		puts
		@board.print_board(player.color)
		result = get_move(player)
		@board.print_board(player.color)
		puts "\t" << result
	end
	
	def play_ai
		result = nil
		while @board.game_over? == false
			puts
			@board.print_board("w")
			puts "\t" << result[2] if result != nil
			result = get_move(@player_white)
			@board.print_board("w")
			puts "\t" << result	
			break if @board.game_over?
			#ai move
			if @board.in_check?("w")
				@board.checkmate?("w")
				result[0] = @board.escape_check_move[0]	
				result[1] = @board.escape_check_move[1]
				result[2] = @player_black.move(result[0].space_number.to_s,result[1].space_number.to_s)
			else
				result = ai_move(@board, @player_black)
				while result[2] == "Error: Your King is exposed."
					result = ai_move(@board, @player_black)
				end
				sleep 0.5
				print "\n\n\n\tComputer calculating next move "
				sleep 0.5
				print "."
				sleep 0.5
				print " ."
				sleep 0.5
				print " ."
				sleep 0.5
				puts
			end
		end

	end

	def menu
		puts "\t-- CHESS --"
		puts "'f': play against a friend\n'a': play against a very dumb ai\n'r': resume saved game\n'q': quit"
		input = gets.chomp.downcase
		if input == "f"
			@mode = "f"
			@player_white.set_opponent(@player_black)
			@player_black.set_opponent(@player_white)
			play_friend
		elsif input == "a"
			@mode = "a"
			@player_white.set_opponent(@player_black)
			@player_black.set_opponent(@player_white)
			play_ai
		elsif input == "r"
			save_state = YAML.load_file("saved_game.yml")
			save_state.get_mode == "f" ? save_state.play_friend : save_state.play_ai
		else
                        exit
		end
	end

	def get_mode
		@mode
	end
end

chess = Chess.new
chess.menu
