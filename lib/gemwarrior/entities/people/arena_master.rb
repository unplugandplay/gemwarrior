# lib/gemwarrior/entities/people/arena_master.rb
# Entity::Creature::Person::ArenaMaster

require_relative '../person'

module Gemwarrior
  class ArenaMaster < Person
    # CONSTANTS
    ARENA_FEE         = 50
    ARENA_MASTER_NAME = 'Iolita'

    def initialize
      super

      self.name         = 'arena_master'
      self.name_display = 'Arena Master'
      self.description  = 'She wears simple clothing, but carries herself with an air of authority. You think she may be the person to talk with if you want to engage in battle.'
    end

    def use(world)
      puts "You approach #{ARENA_MASTER_NAME.colorize(color: :white, background: :black)}, the Arena Master, and ask to prove your mettle in the arena. She snickers to herself, but sees you have a good spirit about you."
      puts

      if world.player.rox >= ARENA_FEE
        print "She asks for the requisite payment: #{ARENA_FEE} rox. Do you pay up? (y/n) "
        answer = gets.chomp.downcase
        
        case answer
        when 'y', 'yes'
          world.player.rox -= ARENA_FEE
          puts
          puts 'She pockets the money and motions toward the center of the arena. She reminds you that you will be facing an ever-worsening onslaught of monsters. Each one you dispatch nets you a bonus cache of rox in addition to whatever the monster gives you. You will also become more experienced the longer you last. Finally, you can give up at any time between battles.'
          puts
          puts 'She finishes by wishing you good luck!'

          return { type: 'arena', data: nil }
        else
          puts
          puts 'She gives you a dirty look, as you have obviously wasted her time. You are told not to mess around with her anymore, and she turns away from you.'
          return { type: nil, data: nil }
        end
      else
        puts 'She can tell you seem particularly poor today and says to come back when that has changed.'
        puts
        return { type: nil, data: nil }
      end
    end
  end
end
