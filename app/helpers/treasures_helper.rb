module TreasuresHelper
  # logic works just like Poke on FB
  def hypeable? user
    able = false
    if current_user and user
      # gets last hypes sent between current and other user for comparison
      last_to_them = user.treasures.where(giver_id: current_user.id).last
      last_from_them = current_user.treasures.where(giver_id: user.id).last
      # if already received hyped from other but haven't reciprocated (or neither have hyped the other)
      if (last_from_them and not last_to_them) or (last_to_them.nil? and last_from_them.nil?)
        able = true
      # if hyped both ways but they hyped last
      elsif last_to_them and last_from_them
        if last_from_them.created_at > last_to_them.created_at
          able = true
        end
      end
    end
    return able
  end
  
  def kanye?
    if @treasure and @treasure.treasure_type.eql? 'kanye'
      true
    end
  end
  
  def treasure_type_options
    options = [['Type of treasure (node type)', nil]]
    Treasure.types.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
  
  def power_options
    options = [['Power to unlock', nil], ['No power', 'no_power']]
    Treasure.powers.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
end
