#
#  Parser Class
#
load "TinyLexer.rb"
load "TinyToken.rb"
load "AST.rb"

class Parser < Lexer

    def initialize(filename)
        super(filename)
        consume()
    end

    def consume()
        @lookahead = nextToken()
        while(@lookahead.type == Token::WS)
            @lookahead = nextToken()
        end
    end

    def match(dtype)
        if (@lookahead.type != dtype)
            puts "Expected #{dtype} found #{@lookahead.text}"
			@errors_found+=1
        end
        consume()
    end

    def program()
    	@errors_found = 0
		
		p = AST.new(Token.new("program","program"))
		
	    while( @lookahead.type != Token::EOF)
            p.addChild(statement())
        end
        
        puts "There were #{@errors_found} parse errors found."
      
		return p
    end

    def statement()
		stmt = AST.new(Token.new("statement","statement"))
        if (@lookahead.type == Token::PRINT)
			stmt = AST.new(@lookahead)
            match(Token::PRINT)
            stmt.addChild(exp())
        else
            stmt = assign()
        end
		return stmt
    end

    def exp()
        term = term()
        if (@lookahead.type == Token::ADDOP or @lookahead.type == Token::SUBOP)
            operator = etail()
            operator.addChild(term)
            return operator
        end
        return term
    end

    def term()
        fct = factor()
        if (@lookahead.type == Token::MULTOP or @lookahead.type == Token::DIVOP)
            operator = ttail()
            operator.addChild(fct)
            return operator
        end
        return fct

        #ttail()
    end

    def factor()
        fct = AST.new(Token.new("factor","factor"))
        if (@lookahead.type == Token::LPAREN)
            match(Token::LPAREN)
            fct = exp()
            #exp()
            if (@lookahead.type == Token::RPAREN)
                match(Token::RPAREN)
            else
				match(Token::RPAREN)
            end
        elsif (@lookahead.type == Token::INT)
            fct = AST.new(@lookahead)
            match(Token::INT)
        elsif (@lookahead.type == Token::ID)
            fct = AST.new(@lookahead)
            match(Token::ID)
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            @errors_found+=1
            consume()
        end
		return fct
    end

    def ttail()
        operator = AST.new(Token.new("operator","operator"))
        if (@lookahead.type == Token::MULTOP)
            operator = AST.new(@lookahead)
            match(Token::MULTOP)
            operator.addChild(factor())
            operator.addChild(ttail())
            #factor()
            #ttail()
        elsif (@lookahead.type == Token::DIVOP)
            operator = AST.new(@lookahead)
            match(Token::DIVOP)
            operator.addChild(factor())
            operator.addChild(ttail())
            #factor()
            #ttail()
		else
			return nil
        end
        return operator
    end

    def etail()
        operator = AST.new(Token.new("operator","operator"))
        if (@lookahead.type == Token::ADDOP)
            operator = AST.new(@lookahead)
            match(Token::ADDOP)
            operator.addChild(term())
            operator.addChild(etail())
            #term()
            #etail()
        elsif (@lookahead.type == Token::SUBOP)
            operator = AST.new(@lookahead)
            match(Token::SUBOP)
            operator.addChild(term())
            operator.addChild(etail())
            #term()
            #etail()
		else
			return nil
        end
        return operator
    end

    def assign()
        assgn = AST.new(Token.new("assignment","assignment"))
		if (@lookahead.type == Token::ID)
			idtok = AST.new(@lookahead)
			match(Token::ID)
			if (@lookahead.type == Token::ASSGN)
				assgn = AST.new(@lookahead)
				assgn.addChild(idtok)
            	match(Token::ASSGN)
				assgn.addChild(exp())
        	else
				match(Token::ASSGN)
			end
		else
			match(Token::ID)
        end
		return assgn
	end
end
