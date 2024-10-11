describe "Services" do
  context ".push_locations" do
    it "returns an array when there are items separated by ||" do
      with_modified_env PUSH_LOCATIONS: "http://pushlocation:12000/example||http://pushlocation:12000/other_example" do
        expect(S.push_locations).to contain_exactly("http://pushlocation:12000/example", "http://pushlocation:12000/other_example")
      end
    end
    it "returns empty array if empty" do
      with_modified_env PUSH_LOCATIONS: nil do
        load(File.join(S.project_root, "lib", "services.rb"))
        expect(S.push_locations).to eq([])
      end
    end
  end
end
