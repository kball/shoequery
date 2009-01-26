load 'shoe_query.rb'
app = Shoes.app do
  para "foo"
  f = flow do
    stack do 
      para "bar"
      para 'blah'
    end
  end
  b = button "click me"
  b.click do
    para shoe_query('para').inspect
    para shoe_query('flow para').inspect
    para shoe_query(f).find('para').inspect
  end
end
