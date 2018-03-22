require "babel_bridge"

# Inherit from Babel bridge parser (alternative to javacc)
class Parser < BabelBridge::Parser
    
    # Deal with whitespaces
    ignore_whitespace
    
    
    # Parsing rules
    # rule definitions allow blocks using "do" function
    
    # Make add rule recursive by allowing multiple numbers "add" rule 2nd version of add funtion allows int only
    # Added regex symbols using special precedence from left to right 
        # Divisions and times happen first
    binary_operators_rule :statement, :operand, [[:/, :*], [:+, :-]] do 
        # Define evaluate on int node
        def evaluate
            # Babel_bridge takes one int subnode then create method to return value
            
            left.evaluate.send operator, right.evaluate
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
BabelBridge::Shell.new(Parser.new).start

