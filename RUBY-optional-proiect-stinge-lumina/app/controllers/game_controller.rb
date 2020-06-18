class GameController < ApplicationController
  def load_game
    @game = Game.where(id: params[:id].to_i)[0]
    if @game.nil?
      redirect_to '/game/index'
      return nil
    end
    @game.load_data

    @users = {}
    @game.data.user_ids.each do |uid|
      @users[uid] = User.find(uid)
    end

    @move_names = Game::MOVE_NAMES

    @available_moves = {}
    (0..Game::GameState::YAHTZEE).each do |i|
      @available_moves[i] = @move_names[i] if @game.data.details[@game.user_to_move_id]['scores'][i].nil?
    end
  end

  def index
    @games = Game.all
  end

  def create
    puts params

    user_id = current_user.id

    valid_uids = [user_id]
    params['user_ids'].each do |u|
      uid = u.to_i
      next if uid == user_id

      valid_uids.push(uid)
    end

    if valid_uids.length == 1
      redirect_to '/game/new'
      return nil
    end

    @game = Game.create(owner_id: user_id, game_data: '', is_finished: false, user_to_move_id: user_id)
    @game.init_data valid_uids

    valid_uids.each do |uid|
      UsersGame.create(user_id: uid, game_id: @game.id)
    end

    GameNotification.create(user_id: user_id, game_id: @game.id)

    redirect_to "/game/#{@game.id}"
  end

  def show
    load_game
  end

  def update
    load_game
    if params["type"] == 're_roll'
      @game.re_roll(params, current_user.id)
    elsif params["type"] == 'chose_move'
      old_uid = @game.user_to_move_id
      @game.chose_move(params, current_user.id)
      new_uid = @game.user_to_move_id

      if old_uid != new_uid
        puts 'Created notification ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        GameNotification.where(user_id: old_uid, game_id: @game.id)[0].destroy
        GameNotification.create(user_id: new_uid, game_id: @game.id)
      end
    end
    redirect_to "/game/#{params['id']}"
  end

  def destroy
    redirect_to '/'
  end
end
