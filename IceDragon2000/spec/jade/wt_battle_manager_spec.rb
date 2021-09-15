require_relative 'spec_helper'
require 'iek/abstract_method_error/load'
require 'sapling/load'
require 'jade/load'
require 'jade/wt/load'

describe Jade::WtBattleManager do
  it 'should initialize' do
    battle_manager = Jade::WtBattleManager.new
  end

  it 'should have a WtPhaseController' do
    battle_manager = Jade::WtBattleManager.new
    expect(battle_manager.phase).to be_kind_of(Jade::WtPhaseController)
  end

  it 'should have a WtEventController' do
    battle_manager = Jade::WtBattleManager.new
    expect(battle_manager.event).to be_kind_of(Jade::WtEventController)
  end

  it 'should have a WtPhaseModel' do
    battle_manager = Jade::WtBattleManager.new
    expect(battle_manager.model).to be_kind_of(Jade::WtPhaseModel)
  end
end
