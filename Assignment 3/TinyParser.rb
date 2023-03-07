#
#  Parser Class
#
load "TinyToken.rb"
load "TinyLexer.rb"
class Parser < Lexer
	def initialize(filename)
		@errors = 0
    	super(filename)
    	consume()
   	end
   	
	def consume()
      	@lookahead = nextToken()
      	while(@lookahead.type == Token::WS)
        	@lookahead = nextToken()
      	end
   	end
  	
	def match(*dtype)
		
		#went into the debugger and found that the lookahead type stores the type in lowercase
		unless dtype.include?(@lookahead.type)
  			dtype.map!(&:upcase) if dtype.length > 1

            puts "Expected #{dtype.join(" or ")} found #{@lookahead.text}"
            @errors += 1
        end
      	consume()
   	end
   	
	def program()
      	while( @lookahead.type != Token::EOF)
        	puts "Entering STMT Rule"
			statement()  
      	end
		puts "There were #{@errors} parse errors found."
   	end

	def ifRule()
		puts "Entering IF Rule"
		if (@lookahead.type == Token::IFOP)
			puts "Found IFOP Token: #{@lookahead.text}"
			comparisonRule()
			match(Token::IFOP)
				if (@lookahead.type == Token::THENOP)
					puts "Found THENOP Token: #{@lookahead.text}"
					match(Token::THENOP)
					statement()
					if (@lookahead.type == Token::ENDOP)
						puts "Found ENDOP Token: #{@lookahead.text}"
						match(Token::ENDOP)
	
					end
				end
		end

		puts "Exiting IF Rule"
	end

	def comparisonRule()
		factorRule()
		puts "Entering COMPARISON Rule"
		if (@lookahead.type == Token::GT)
			puts "Found GT Token: #{@lookahead.text}"
			match(Token::MTCOMPARISON)
			factorRule()
		elsif (@lookahead.type == Token::LT)
			puts "Found LT Token: #{@lookahead.text}"
			match(Token::LTCOMPARISON)
			factorRule()
		elsif (@lookahead.type == Token::ANDOP)
			puts "Found ANDOP Token: #{@lookahead.text}"
			match(Token::ANDOP)
			factorRule()
		end
		puts "Exiting COMPARISON Rule"
	end

	def whileRule()
		puts "Entering WHILE Rule"
		if (@lookahead.type == Token::WHILEOP)
			puts "Found WHILEOP Token: #{@lookahead.text}"
			match(Token::WHILEOP)
			comparisonRule()
			if (@lookahead.type == Token::THENOP)
				puts "Found THENOP Token: #{@lookahead.text}"
				match(Token::THENOP)
				statement()
				if (@lookahead.type == Token::ENDOP)
					puts "Found END Token: #{@lookahead.text}"
					match(Token::ENDOP)
				end
			end
		end
		puts "Exiting WHILE Rule"
	end



	def statement()

		if (@lookahead.type == Token::PRINT)
			puts "Found PRINT Token: #{@lookahead.text}"
			match(Token::PRINT)
			expRule()
		elsif (@lookahead.type == Token::WHILEOP)
			whileRule()
		elsif (@lookahead.type == Token::IFOP)
			ifRule()
		else
			assign()
			
		end
		
		puts "Exiting STMT Rule"
	end

	def assign()
		puts "Entering ASSGN Rule"
		idRule()
		if (@lookahead.type == Token::ASSGN)
			puts "Found ASSGN Token: #{@lookahead.text}"
			match(Token::ASSGN)
		else
			match(Token::ASSGN)
		end
		expRule()
		puts "Exiting ASSGN Rule"
	end

	def idRule()
		#puts "Entering ID Rule"
		if (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			match(Token::ID)
		else
			match(Token::ID)
		end
		#puts "Exiting ID Rule"
	end

	def expRule()
		puts "Entering EXP Rule"
		termRule()
		etailRule()
		puts "Exiting EXP Rule"
	end

	def termRule()
		puts "Entering TERM Rule"
		factorRule()
		ttailRule()
		puts "Exiting TERM Rule"
	end

	def etailRule()
		puts "Entering ETAIL Rule"
		if (@lookahead.type == Token::ADDOP)
			puts "Found ADDOP Token: #{@lookahead.text}"
			match(Token::ADDOP)
			termRule()
			etailRule()
		elsif (@lookahead.type == Token::SUBOP)
			puts "Found SUBOP Token: #{@lookahead.text}"
			match(Token::SUBOP)
			termRule()
			etailRule()
		else
			puts "Did not find ADDOP or SUBOP Token, choosing EPSILON production"
		end
		puts "Exiting ETAIL Rule"
	end

	def factorRule()
		puts "Entering FACTOR Rule"
		if (@lookahead.type == Token::LPAREN)
			puts "Found LPAREN Token: #{@lookahead.text}"
			match(Token::LPAREN)
			expRule()
			if (@lookahead.type == Token::RPAREN)
				puts "Found RPAREN Token: #{@lookahead.text}"
				match(Token::RPAREN)
			else
				match(Token::RPAREN)
			end
		
		elsif (@lookahead.type == Token::INT)
			intRule()
		elsif (@lookahead.type == Token::ID)
			idRule()
		else
			match(Token::LPAREN, Token::INT, Token::ID)
		end
		puts "Exiting FACTOR Rule"

	end

	def ttailRule()
		puts "Entering TTAIL Rule"
		if (@lookahead.type == Token::MULTOP)
			puts "Found MULTOP Token: #{@lookahead.text}"
			match(Token::MULTOP)
			factorRule()
			ttailRule()
		elsif (@lookahead.type == Token::DIVOP)
			puts "Found DIVOP Token: #{@lookahead.text}"
			match(Token::DIVOP)
			factorRule()
			ttailRule()
		else
			puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
		end
		puts "Exiting TTAIL Rule"
	end

	def intRule()
		#puts "Entering INT Rule"
		if (@lookahead.type == Token::INT)
			puts "Found INT Token: #{@lookahead.text}"
			match(Token::INT)
		else
			match(Token::INT)
		end
		#puts "Exiting INT Rule"
	end
	



end

