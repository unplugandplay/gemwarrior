# lib/gemwarrior/world.rb
# World where the locations, monsters, items, etc. exist

require_relative 'game_options'
require_relative 'inventory'
require_relative 'entities/item'
require_relative 'entities/items/herb'
require_relative 'entities/location'
require_relative 'entities/player'

module Gemwarrior
  class World
    # CONSTANTS
    ERROR_LIST_PARAM_INVALID      = 'That is not something that can be listed.'
    ERROR_DESCRIBE_ENTITY_INVALID = 'You do not see that here.'
    WORLD_DIM_WIDTH               = 10
    WORLD_DIM_HEIGHT              = 10

    attr_accessor :monsters, :locations, :player, :duration, :emerald_beaten

    def print_vars
      puts "======================\n"
      puts "All Variables in World\n"
      puts "======================\n"
      puts "#{list('players', true)}\n"
      puts "#{list('monsters', true)}\n\n"
      puts "#{list('items', true)}\n\n"
      puts "#{list('locations', true)}\n"
    end

    def print_map(floor)
      0.upto(WORLD_DIM_HEIGHT - 1) do |count_y|
        print '  '
        0.upto(WORLD_DIM_WIDTH - 1) do
          print '---'
        end
        print "\n"
        print "#{(WORLD_DIM_HEIGHT - 1) - count_y} "
        0.upto(WORLD_DIM_WIDTH - 1) do |count_x|
          cur_map_coords = {
            x: count_x,
            y: (WORLD_DIM_HEIGHT - 1) - count_y,
            z: floor.nil? ? self.player.cur_coords[:z] : floor.to_i
          }
          if self.player.cur_coords.eql?(cur_map_coords)
            print '|O|'
          elsif location_by_coords(cur_map_coords)
            print '|X|'
          else
            print '| |'
          end
        end
        print "\n"
      end
      print '  '
      0.upto(WORLD_DIM_WIDTH - 1) do
        print '---'
      end
      puts
      print '   '
      0.upto(WORLD_DIM_WIDTH - 1) do |count_x|
        print "#{count_x}  "
      end
      if GameOptions.data['debug_mode']
        puts
        puts
        puts "Current level: #{player.cur_coords[:z]}"
        puts '| | = invalid location'
        puts '|X| = valid location'
        puts '|O| = player'
      end
      return
    end

    def list(param, details = false)
      case param
      when 'players'
        puts '[PLAYERS]'
        player.check_self(false)
      when 'monsters'
        puts "[MONSTERS](#{monsters.length})".colorize(:yellow)
        if details
          monsters.map { |m| print m.describe }
          return
        else
          ">> monsters: #{monsters.map(&:name).join(', ')}"
        end
      when 'items'
        item_count = 0
        locations.each do |l|
          l.items.each do
            item_count += 1
          end
        end
        puts "[ITEMS](#{item_count})".colorize(:yellow)
        if details
          locations.each do |l|
            l.items.map { |i| print i.describe }
          end
          return
        else
          item_list = []
          locations.each do |l|
            l.items.map { |i| item_list << i.name }
          end
          ">> #{item_list.sort.join(', ')}"
        end
      when 'locations'
        puts "[LOCATIONS](#{locations.length})".colorize(:yellow)
        if details
          locations.map { |l| print l.status }
          return
        else
          ">> #{locations.map(&:name).join(', ')}"
        end
      else
        ERROR_LIST_PARAM_INVALID
      end
    end

    def location_by_coords(coords)
      locations.each do |l|
        if l.coords.eql?(coords)
          return l
        end
      end
      return nil
    end

    def location_coords_by_name(name)
      locations.each do |l|
        if l.name.downcase.eql?(name.downcase)
          return l.coords
        end
      end
      return nil
    end

    def describe(point)
      desc_text = ''
      desc_text << "[>>> #{point.name.upcase} <<<]".colorize(:cyan)

      if GameOptions.data['debug_mode']
        desc_text << " DL[#{point.danger_level.to_s}] MLR[#{point.monster_level_range.to_s}]".colorize(:yellow)
      end

      desc_text << "\n"
      desc_text << point.description.colorize(:green)

      point.populate_monsters(self.monsters) unless point.checked_for_monsters?

      desc_text << "\n >> Monster(s):  #{point.list_monsters.join(', ')}".colorize(:yellow) unless point.list_monsters.empty?
      desc_text << "\n >> Boss(es):    #{point.list_bosses.join(', ')}".colorize(:red) unless point.list_bosses.empty?
      desc_text << "\n >> Thing(s):    #{point.list_items.join(', ')}".colorize(:white) unless point.list_items.empty?
      desc_text << "\n >> Path(s):     #{point.list_paths.join(', ')}".colorize(:white)

      if GameOptions.data['debug_mode']
        desc_text << "\n >>> Actionable: ".colorize(color: :red, background: :grey)
        desc_text << point.list_actionable_words.colorize(color: :white, background: :grey)
      end

      return desc_text
    end

    def describe_entity(point, entity_name)
      entity_name.downcase!

      if point.has_item?(entity_name)
        point.items.each do |i|
          if i.name.downcase.eql?(entity_name)
            if GameOptions.data['debug_mode']
              return i.describe
            else
              return i.description
            end
          end
        end
      elsif point.has_monster?(entity_name)
        point.monsters_abounding.each do |m|
          if m.name.downcase.eql?(entity_name)
            if GameOptions.data['debug_mode']
              return m.describe
            else
              return m.description
            end
          end
        end
      elsif point.has_boss?(entity_name)
        point.bosses_abounding.each do |b|
          if b.name.downcase.eql?(entity_name)
            if GameOptions.data['debug_mode']
              return b.describe
            else
              return b.description
            end
          end
        end
      elsif player.inventory.contains_item?(entity_name)
        player.inventory.describe_item(entity_name)
      else
        ERROR_DESCRIBE_ENTITY_INVALID
      end
    end

    def can_move?(direction)
      location_by_coords(player.cur_coords).has_loc_to_the?(direction)
    end

    def has_monster_to_attack?(monster_name)
      possible_combatants = location_by_coords(player.cur_coords).monsters_abounding.map(&:name) | location_by_coords(player.cur_coords).bosses_abounding.map(&:name)

      possible_combatants.each do |combatant|
        if combatant.downcase.eql?(monster_name.downcase)
          return true
        end
      end

      return false
    end
  end
end
