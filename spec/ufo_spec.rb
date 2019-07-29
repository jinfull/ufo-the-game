require "ufo"

RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end


describe "UFO" do
  let(:ufo) { UFO.new }

  describe "DICTIONARY" do
    it "should be an array of words" do
      expect(DICTIONARY).to be_an(Array)
    end
  end

  describe "::random_word" do
    it "should return a random word in the dictionary" do
      expect(DICTIONARY).to include(UFO.random_word.downcase)
    end
  end

  describe "#initialize" do
    it "should set @code_word with the random word " do
      allow(UFO).to receive(:random_word).and_return("actor")
      expect(ufo.instance_variable_get(:@code_word)).to eq("actor")
    end

    it "should set @guess_word to be an array with the same length as the @code_word containing '_' as each element" do
      allow(UFO).to receive(:random_word).and_return("acid")
      expect(UFO.new.instance_variable_get(:@guess_word)).to eq(Array.new(4, "_"))

      allow(UFO).to receive(:random_word).and_return("acoustic")
      expect(UFO.new.instance_variable_get(:@guess_word)).to eq(Array.new(8, "_"))
    end

    it "should set @correctly_guessed to be an empty array" do
      expect(ufo.instance_variable_get(:@correctly_guessed)).to eq([])
    end

    it "should set @incorrectly_guessed to be an empty array" do
      expect(ufo.instance_variable_get(:@incorrectly_guessed)).to eq([])
    end

    it "should set @remaining_guesses to 6" do
      expect(ufo.instance_variable_get(:@remaining_guesses)).to eq(6)
    end
  end

  describe "#guess_word" do
    it "should get (return) @guess_word" do
      expect(ufo.guess_word).to be(ufo.instance_variable_get(:@guess_word))
    end
  end

  describe "#correctly_guessed" do
    it "should get (return) @correctly_guessed" do
      expect(ufo.correctly_guessed).to be(ufo.instance_variable_get(:@correctly_guessed))
    end
  end

  describe "#incorrectly_guessed" do
    it "should get (return) @incorrectly_guessed" do
      expect(ufo.incorrectly_guessed).to be(ufo.instance_variable_get(:@incorrectly_guessed))
    end
  end

  describe "#remaining_guesses" do
    it "should get (return) @remaining_guesses" do
      expect(ufo.remaining_guesses).to be(ufo.instance_variable_get(:@remaining_guesses))
    end
  end

  describe "#already_guessed?" do
    it "should accept a char as an arg" do
      ufo.already_guessed?("b")
    end

    context "when the given char is in @correctly_guessed" do
      it "should return true" do
        ufo.instance_variable_set(:@correctly_guessed, ["b"])
        expect(ufo.already_guessed?("b")).to eq(true)
      end
    end

    context "when the given char is not in @correctly_guessed" do
      it "should return false" do
        ufo.instance_variable_set(:@correctly_guessed, ["b"])
        expect(ufo.already_guessed?("c")).to eq(false)
      end
    end
  end

  describe "#get_matching_indices" do
    it "should accept a single char as an arg" do
      ufo.get_matching_indices("o")
    end

    it "should return an array containing all indices of @code_word where the char can be found" do
      allow(UFO).to receive(:random_word).and_return("bootcamp")
      expect(ufo.get_matching_indices("o")).to eq([1, 2])
      expect(ufo.get_matching_indices("c")).to eq([4])
    end

    context "when the char is not found in @code_word" do
      it "should return an empty array" do
        allow(UFO).to receive(:random_word).and_return("bootcamp")
        expect(ufo.get_matching_indices("x")).to eq([])
      end
    end
  end

  describe "#fill_indices" do
    it "should accept a char and an array of indices" do
      allow(UFO).to receive(:random_word).and_return("bootcamp")
      ufo.fill_indices("o", [1, 2])
    end

    it "should set the given indices of @guess_word to the given char" do
      allow(UFO).to receive(:random_word).and_return("bootcamp")
      ufo.fill_indices("o", [1, 2])
      expect(ufo.guess_word).to eq(["_", "o", "o", "_", "_", "_", "_", "_"])
    end
  end

  describe "#try_guess" do
    it "should accept a char as an arg" do
      ufo.try_guess("o")
    end

    it "should call UFO#already_guessed?" do
      expect(ufo).to receive(:already_guessed?).with("o")
      ufo.try_guess("o")
    end

    context "if the char was already guessed" do
      it "should print 'You can only guess that letter once'" do
        ufo.instance_variable_set(:@correctly_guessed, ["o"])
        expect { ufo.try_guess("o") }.to output(/You can only guess that letter once/).to_stdout
      end

      it "should return false to indicate the guess was previously attempted" do
        ufo.instance_variable_set(:@correctly_guessed, ["o"])
        expect(ufo.try_guess("o")).to eq(false)
      end
    end

    context "if the char was not already guessed" do
      it "should add the char to @incorrectly_guessed (for incorrect guess)" do
        ufo.try_guess("o")
        expect(ufo.incorrectly_guessed).to eq(["o"])

        ufo.try_guess("c")
        expect(ufo.incorrectly_guessed).to eq(["o", "c"])

        ufo.try_guess("x")
        expect(ufo.incorrectly_guessed).to eq(["o", "c", "x"])
      end

      it "should return true to indicate the guess was not previously attempted" do
        expect(ufo.try_guess("o")).to eq(true)
      end
    end

    context "if the char has no match indices in @code_word" do
      it "should decrement @remaining_guesses" do
        allow(UFO).to receive(:random_word).and_return("bootcamp")

        ufo.try_guess("o")
        expect(ufo.remaining_guesses).to eq(6)

        ufo.try_guess("x")
        expect(ufo.remaining_guesses).to eq(5)
      end
    end

    it "should call UFO#get_matching_indices with the char" do
      allow(UFO).to receive(:random_word).and_return("bootcamp")
      allow(ufo).to receive(:get_matching_indices) { [1, 2] }
      expect(ufo).to receive(:get_matching_indices).with("o")
      ufo.try_guess("o")
    end

    it "should call UFO#fill_indices with the char and it's matching indices" do
      allow(UFO).to receive(:random_word).and_return("bootcamp")
      expect(ufo).to receive(:fill_indices).with("o", [1, 2])
      ufo.try_guess("o")
    end
  end

  describe "#ask_user_for_guess" do
    it "should print 'enter your guess:'" do
      allow(ufo).to receive(:gets).and_return("o\n")
      expect { ufo.ask_user_for_guess }.to output(/enter your guess/).to_stdout
    end

    it "should call gets.chomp to get input from the user " do
      char = double("o\n", :chomp => "o")
      allow(ufo).to receive(:gets).and_return(char)
      expect(char).to receive(:chomp)
      expect(ufo).to receive(:gets)
      ufo.ask_user_for_guess
    end

    it "should call UFO#try_guess with the user's char" do
      char = double("o\n", :chomp => "o")
      allow(ufo).to receive(:gets).and_return(char)
      expect(ufo).to receive(:try_guess).with(char.chomp.upcase)
      ufo.ask_user_for_guess
    end

    it "should return the return value of UFO#try_guess" do
      char = double("o\n", :chomp => "o")
      allow(ufo).to receive(:gets).and_return(char)

      allow(ufo).to receive(:try_guess).and_return(false)
      expect(ufo.ask_user_for_guess).to eq(false)

      allow(ufo).to receive(:try_guess).and_return(true)
      expect(ufo.ask_user_for_guess).to eq(true)
    end
  end

  describe "win?" do
    context "when @guess_word matches @secret_word" do
      it "should return true" do
        allow(UFO).to receive(:random_word).and_return("cat")
        ufo.instance_variable_set(:@guess_word, ["c", "a", "t"])
        expect(ufo.win?).to eq(true)
      end
    end

    context "when @guess_word does not match @secret_word" do
      it "should return false" do
        allow(UFO).to receive(:random_word).and_return("cat")
        ufo.instance_variable_set(:@guess_word, ["c", "_", "t"])
        expect(ufo.win?).to eq(false)
      end
    end
  end

  describe "lose?" do
    context "when @remaining_guesses is 0" do
      it "should return true" do
        ufo.instance_variable_set(:@remaining_guesses, 0)
        expect(ufo.lose?).to eq(true)
      end
    end

    context "when @remaining_guesses is not 0" do
      it "should return false" do
        ufo.instance_variable_set(:@remaining_guesses, 2)
        expect(ufo.lose?).to eq(false)
      end
    end
  end

  describe "game_over?" do
    it "should call UFO#win?" do
      allow(ufo).to receive(:lose?).and_return(false)
      allow(ufo).to receive(:win?).and_return(true)
      expect(ufo).to receive(:win?)
      ufo.game_over?
    end

    it "should call UFO#lose?" do
      allow(ufo).to receive(:win?).and_return(false)
      allow(ufo).to receive(:lose?).and_return(true)
      expect(ufo).to receive(:lose?)
      ufo.game_over?

    end

    context "when the game is won or lost" do
      it "should return true" do
        allow(ufo).to receive(:lose?).and_return(false)
        allow(ufo).to receive(:win?).and_return(true)
        expect(ufo.game_over?).to eq(true)

        allow(ufo).to receive(:lose?).and_return(true)
        allow(ufo).to receive(:win?).and_return(false)
        expect(ufo.game_over?).to eq(true)
      end
    end

    context "when the game is not over" do
      it "should return false" do
        allow(ufo).to receive(:lose?).and_return(false)
        allow(ufo).to receive(:win?).and_return(false)
        expect(ufo.game_over?).to eq(false)
      end
    end
  end

  describe "bonus feature!" do 
    describe "regexp_guess_word" do
      it "should generate a matching regexp" do
        ufo.instance_variable_set(:@guess_word, ['B', 'A', 'B', '_'])
        expect(ufo.regexp_guess_word).to eq(/bab./)
      end
    end

    describe "bonus" do 
      it "should return the correct number of matching regexps in dictionary" do
        ufo.instance_variable_set(:@guess_word, ['B', 'A', 'B', '_'])
        ufo.regexp_guess_word
        expect(ufo.bonus).to eq(5)
      end
    end
  end
end