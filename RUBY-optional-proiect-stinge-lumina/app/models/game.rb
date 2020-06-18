class Game < ApplicationRecord
  has_many :users_games
  has_many :users, through: :users_games

  MOVE_NAMES = [
      'only 1',
      'only 2',
      'only 3',
      'only 4',
      'only 5',
      'only 6',
      'pair',
      'two pairs',
      'three of a kind',
      'full house',
      'four of a kind',
      'YAHTZEE'
  ]

  attr_accessor :data

  def re_roll(params, user_id)
    if user_id != user_to_move_id || @data.can_re_roll_dices == false
      return nil
    end

    @data.re_roll_dices(params)
    update_data
  end

  def chose_move(params, user_id)
    puts 'CHOSE MOVEEEE'
    puts user_id
    puts user_to_move_id
    if user_id != user_to_move_id
      return nil
    end

    m = params["move_id"].to_i
    puts '``````'
    puts m
    puts params
    puts @data.to_json
    puts '``````'

    if (params['move_id'] != '0' && m == 0) || (params['move_id'] == '')
      return nil
    end

    if @data.can_make_move(m) == false
      return nil
    end

    @data.make_move(m)
    update_data
  end

  def init_data(uids)
    @data = GameState.new
    @data.init(uids)
    update_data
  end

  def update_data
    update!(game_data: @data.to_json, user_to_move_id: @data.current_user)
  end

  def load_data
    @data = GameState.new
    puts @game_data
    @data.from_json! game_data
  end

  class JSONable
    def to_json
      hash = {}

      self.instance_variables.each do |var|
        hash[var.to_s] = self.instance_variable_get(var)
      end
      hash.to_json
    end
    def from_json! string
      JSON.load(string).each do |var, val|
        self.instance_variable_set var, val
      end
    end
  end

  class UserDetail < JSONable
    attr_accessor :id
    attr_accessor :score
    attr_accessor :scores
    attr_accessor :last_move

    def init(uid)
      @last_move = -1
      @id = uid
      @score = 0
      @scores = Array.new(12, nil)
    end
  end

  class GameState < JSONable
    ROLL = 1
    SELECT_OPTION = 2

    S_1 = 0
    S_2 = 1
    S_3 = 2
    S_4 = 3
    S_5 = 4
    S_6 = 5
    PAIR = 6
    TWO_PAIRS = 7
    THREES = 8
    FULL_HOUSE = 9
    FOURS = 10
    YAHTZEE = 11

    attr_accessor :step
    attr_accessor :dices
    attr_accessor :details

    attr_accessor :user_ids
    attr_accessor :current_user_index
    attr_accessor :current_scores

    # init stuff
    def initialize
      @step = ROLL
      @dices = new_dices 5
      update_scores
    end

    def init(user_ids)
      @current_user_index = 0
      @user_ids = user_ids
      @details = {}
      @user_ids.each do |uid|
        ud = UserDetail.new
        ud.init(uid)
        @details[uid.to_s] = ud
      end
    end

    def from_json!(s)
      super s
      user_ids.each do |uid|
        details[uid] = details[uid.to_s]
        details.delete uid.to_s
      end
    end

    # information
    def current_user
      @user_ids[@current_user_index]
    end

    def can_make_move(move)
      @details[@user_ids[@current_user_index]][move].nil? && @step == SELECT_OPTION
    end

    def make_move(move)
      @details[@user_ids[@current_user_index]]['scores'][move] = @current_scores[move]
      @details[@user_ids[@current_user_index]]['score'] += @current_scores[move]
      @details[@user_ids[@current_user_index]]['last_move'] = move.to_s

      @current_user_index += 1
      @current_user_index %= @user_ids.length
      @step = ROLL

      @dices = new_dices(5)
      update_scores
    end

    def can_re_roll_dices
      @step == ROLL
    end

    def re_roll_dices(param)
      remaining_dices = []

      (0..4).each do |i|
        if param[i.to_s.to_sym] == '1'
          remaining_dices.push(@dices[i])
        end
      end

      @dices = remaining_dices + new_dices(5 - remaining_dices.length)
      @step = SELECT_OPTION
      update_scores
    end

    # util stuff

    def new_dices(num_dices)
      dices = []
      (1..num_dices).each do |_|
        dices.push(rand(1..6))
      end
      dices
    end

    # scoring stuff
    def update_scores
      @current_scores = single_scores + [
        pair,
        two_pairs,
        threes,
        full_house,
        fours,
        yahtzee
      ]
    end

    def single_scores
      scores = [0, 0, 0, 0, 0, 0]
      @dices.each do |d|
        scores[d - 1] += d
      end
      scores
    end

    def pair
      mx = 0
      @dices.permutation.each do |dices|
        mx = [mx, dices[0] * 2].max if dices[0] == dices[1]
      end
      mx
    end

    def two_pairs
      mx = 0
      @dices.permutation.each do |dices|
        mx = [mx, dices[0] * 2 + dices[2] * 2].max if dices[0] == dices[1] && dices[2] == dices[3]
      end
      mx
    end

    def threes
      mx = 0
      @dices.permutation.each do |dices|
        mx = [mx, dices[0] * 3].max if dices[0] == dices[1] && dices[1] == dices[2]
      end
      mx
    end

    def fours
      mx = 0
      @dices.permutation.each do |dices|
        mx = [mx, dices[0] * 4].max if dices[0] == dices[1] && dices[1] == dices[2] && dices[2] == dices[3]
      end

      if mx != 0
        mx = [mx, 25].max
      else
        0
      end
    end

    def full_house
      mx = 0
      @dices.permutation.each do |dices|
        mx = [mx, dices[0] * 2 + dices[2] * 3].max if dices[0] == dices[1] && dices[2] == dices[3] && dices[3] == dices[4]
      end
      mx
    end

    def yahtzee
      if @dices == Array.new(5, @dices[0])
        50
      else
        0
      end
    end
  end
end