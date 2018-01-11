module ConnectionsHelper
  def select_number_options label="", num=1
    options = [[label, nil]]
    (1..num).each do |n|
      options << n
    end
    return options
  end
end
