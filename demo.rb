load 'shoe_query.rb'
app = Shoes.app do
  para "In Main App - also longest para"
  f = flow do
    para "In Flow"
    stack do 
      para 'In Stack'
    end
    para 'In Flow'
  end
  b = button "Change all paragraphs"
  b.click do
    shoe_query('para').text("all ps").stroke(red)
  end
  b2 = button "Change the paragraphs inside the flow"
  b2.click do
    shoe_query('flow').find('para').each {|p| p.text = "flow ps"}
  end
  b3 = button "Change the paragraphs inside the stack"
  b3.click do
    shoe_query('stack para').each {|p| p.text = "stack p"}
  end
  b4 = button "Change paragraphs with length > 10"
  b4.click do
    shoe_query('para').find do |p|
      p.to_s.size > 10
    end.text("I was a long para!")
  end

  b5 = button "Click me to take control of all buttons"
  b5.click do
    shoe_query('para').each {|p| p.remove}
    para "Try clicking another button again"
    shoe_query('button').click do
      para "All your button are belong to us now"
    end
  end


end
