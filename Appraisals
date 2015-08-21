["3.2", "4.0", "4.2"].each do |version|
  appraise version.sub(".", "") do
    gem "activerecord", "~> #{version}.0"
  end
end
