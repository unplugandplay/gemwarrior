# lib/gemwarrior/entities/items/letter.rb
# Item::Letter

require_relative '../item'

module Gemwarrior
  class Letter < Item
    def initialize
      self.name         = 'letter'
      self.description  = 'A single page of thin paper, folded at the middle, with some excellent penmanship impressed upon it.'
      self.atk_lo       = nil
      self.atk_hi       = nil
      self.takeable     = true
      self.useable      = true
      self.equippable   = false
      self.equipped     = false
      self.used         = false
    end

    def use(player = nil)
      if self.used
        puts 'Do you want to read the letter again? (Y/N)'
        print '> '

        choice = STDIN.getch

        case choice
        when 'y'
          print "\n"
          print_letter(player)
        else
          {:type => nil, :data => nil}
        end
      else
        self.used = true
        print_letter(player)
        {:type => 'xp', :data => 3}
      end
    end

    private

    def print_letter(player)
      puts 'The words of the queen echo in your head as you read the royal note sent to you again:'
      puts
      Animation::run({phrase: "  Dear #{player.name},", speed: :insane})
      puts
      Animation::run({phrase: "    Oh, my! Jool is in trouble! The evil wizard/sorceror/conjuror/rocksmith/wily ", speed: :insane})
      Animation::run({phrase: "    Emerald has absconded with our ShinyThing(tm)! It is vital that you, #{player.name}, ", speed: :insane})
      Animation::run({phrase: "    go to his tower in the sky in order to retrieve it before he does something terrible with it!", speed: :insane})
      puts
      Animation::run({phrase: "    Remember that one time you came to the castle, trying to sell stones you pilfered from a nearby cave? ", speed: :insane})
      Animation::run({phrase: "    Remember how I laughed and told you to leave at once or I\'d have the royal guard take your head off? Ha! ", speed: :insane})
      Animation::run({phrase: "    What a fool I was to cast such a special person out, as a mysterious stranger in the night told me, before ", speed: :insane})
      Animation::run({phrase: "    mysteriously disappearing, that you, #{player.name}, are actually the only one who can save us (for some reason, ", speed: :insane})
      Animation::run({phrase: "    but that's mysterious strangers for you, right?)!", speed: :insane})
      puts
      Animation::run({phrase: "    Please, I beg of you, save Jool from the potential terror that Emerald could possibly wreak on all ", speed: :insane})
      Animation::run({phrase: "    of us before it is too late! If you do, you, #{player.name}, will be rewarded handsomely!", speed: :insane})
      puts
      Animation::run({phrase: '  Sincerely,', speed: :insane});
      Animation::run({phrase: '  Queen Ruby', speed: :insane});
    end
  end
end
