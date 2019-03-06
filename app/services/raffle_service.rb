class RaffleService
  def initialize(campaign)
    @campaign = campaign
  end

  def call
    return false if @campaign.members.count < 3

    results = {}
    members_list = @campaign.members
    friends_list = @campaign.members
    i = 0
    count = 0

    while(members_list.count != i)
      member = members_list[i]
      i += 1

      loop do
        friend = friends_list.sample

        if friends_list.count == 1 and friend == member
          results = {}
          members_list = @campaign.members
          friends_list = @campaign.members
          count = 0
          i = 0
          break
        elsif friend != member and results[friend] != member
          results[member] = friend
          friends_list -= [friend]
          count = 0
          break
        end

        if count > members_list.count
          results = {}
          members_list = @campaign.members
          friends_list = @campaign.members
          count = 0
          i = 0
          break
        end

        count += 1
      end
    end
    results
  end

end
