require "babel_bridge"

# Inherit from Babel bridge parser (alternative to javacc)
class TuringParser < BabelBridge::Parser
    
    # Deal with whitespaces
    ignore_whitespace
    
    # Store in memory
    def store
        # Store starts with an empty array
        @store||=[]
    end
    
    # Multiple statements
    # Match as many statements as needed delimited by semicolon
    rule :statements, many(:statement,";"), match?(";") do
        # Return last statement evaluated and evaluate in order
        def evaluate
          ret = nil
          statement.each do |s|
            ret = s.evaluate
          end
          ret
        end
      end
    
    # If statement is 
    rule :statement, "if", :statement, "then", :statements, :else_clause?, "end" do
        def evaluate
            # Matching the 2nd statement "If" 
            if statement[0].evaluate
                statement[1].evaluate
            else
                else_clause.evaluate if else_clause
            end 
        end
    end
    
    rule :else_clause, "else", :statements
    
    # While statements
    # While follwed by statement followed by do followed by final statements then end
    rule :statement, "while", :statement, "do", :statements, "end" do
        def evaluate
            # Use ruby while statement
            while statement.evaluate
                statements.evaluate
            end
        end
    end

    
    # Parsing rules
    # rule definitions allow blocks using "do" function
    
    # Make add rule recursive by allowing multiple numbers "add" rule 2nd version of add funtion allows int only
    # Added regex symbols using special precedence from left to right 
        # Divisions and times happen first
    binary_operators_rule :statement, :operand, [[:/, :*], [:+, :-], [:<, :<=, :>, :>=, :==]] do
        def evaluate
          case operator
          when :<, :<=, :>, :>=, :==
            (left.evaluate.send operator, right.evaluate) ? 1 : nil
          else
            left.evaluate.send operator, right.evaluate
          end
        end
    end
    
    # Write to the memory store
    # With multiple statements first statement gives index
    rule :operand, "[", :statement, "]", "=", :statement do
        def evaluate
            # Each node returns current parser, parser.store accesses store for parser
            parser.store[statement[0].evaluate] = statement[1].evaluate
        end
    end
    
    # Read from memory store
    rule :operand, "[", :statement, "]" do
        def evaluate
            # access store and retireve statement value
            parser.store[statement.evaluate]
        end
    end
    
    
    # Precedence overide
    rule :operand, "(", :statement, ")"
    
    # Rule name: int, Reg expressions to match rule using positiv and negative ints 
    rule :operand, /[-]?[0-9]+/ do

        # evaluate expression
        def evaluate
            # Convert (to_s) parse tree node to a string to return matching chars 
            # Then convert (to_i) to int as this function only needs to work out int expressions
            to_s.to_i
        end
    end
end

# Using babelbridge shell and giving it instance of parser
BabelBridge::Shell.new(TuringParser.new).start