get "/style2.css" do
  content_type "text/css"
  sass :style
end

get "/" do
  @calls = Call.all(:order => [:created_at.desc], :limit => 5, :completed.eql => true, :cancelled.eql => false)
  haml :home
end

get "/credits" do
  haml :credits
end