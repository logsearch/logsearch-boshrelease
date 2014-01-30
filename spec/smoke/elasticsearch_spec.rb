describe "elasticsearch cluster" do
	it "should report cluster state ok" do 
	  get("/")[:ok] == true
	end
end