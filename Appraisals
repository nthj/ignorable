["3.2", "4.0"].each do |version|
  appraise version.sub(".", "") do
    gem "activerecord", "~> #{version}.0"
  end
end
