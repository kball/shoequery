load 'shoe_query.rb'
app = Shoes.app do
  para "foo"
  f = flow do
    para "bar"
    stack do 
      para 'blah'
    end
  end
  b = button "click me to change all paragraphs"
  b.click do
    shoe_query('para').each {|p| p.text = "all ps" }
  end
  b2 = button "click me to just change the paragraphs inside the flow"
  b2.click do
    shoe_query('flow').find('para').each {|p| p.text = "flow ps"}
  end
  b3 = button "click me to change the button inside the stack"
  b3.click do
    shoe_query('stack para').each {|p| p.text = "stack p"}
  end

end
