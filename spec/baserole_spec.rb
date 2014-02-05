require 'moosex'

module RoleTest
	module Name
		include MooseX

		has name: { is: :rw , required: true }
	end

	module Address
		include MooseX

		has address: { is: :rw , required: true }
	end

	class Person
		include Name
		include Address

		has age: { is: :rw, required: true }
	end

	class Alien
		include Name
		include Address

		has race: { is: :rw, required: true }
	end	

	class FederationCitizen < Person
		has starship: { is: :rw, required: true }
	end

	module Nameadress
		include Name
		include Address

		has complement: { is: :rw, required: true}
	end	

	class Enemy
		include Nameadress
		
		has weapons: { is: :rw, required: true}
	end

	class AlienX
		include MooseX
		include Name
		include Address

		has race: { is: :rw, required: true }
		has x: { is: :rw, required: true }
	end			
end

describe RoleTest::Person do
	it "should create a new instance" do
		RoleTest::Person.new( name: "john", address: "vulcano", age: 18)
	end

	it "should has a name" do
		a = RoleTest::Person.new(name: "john", address: "vulcano", age: 18)

		a.name.should == "john"
		a.address.should == "vulcano"
		a.age.should == 18

		a.name = "b"
		a.address = "Earth"
		a.age = 120

		a.name.should == "b"
		a.address.should == "Earth"
		a.age.should == 120
	end
end	

describe RoleTest::Alien do
	it "should create a new instance" do
		RoleTest::Alien.new( name: "john", address: "vulcano", race: :klingon)
	end

	it "should has a name" do
		a = RoleTest::Alien.new(name: "john", address: "vulcano", race: :klingon)

		a.name.should == "john"
		a.address.should == "vulcano"
		a.race.should == :klingon

		a.name = "b"
		a.address = "Earth"
		a.race = :borg

		a.name.should == "b"
		a.address.should == "Earth"
		a.race.should == :borg
	end
end	

describe RoleTest::FederationCitizen do
	it "should create a new instance" do
		RoleTest::FederationCitizen.new( name: "john", address: "vulcano", age: 18, starship: :enterprise)
	end

	it "should has a name" do
		a = RoleTest::FederationCitizen.new(name: "john", address: "vulcano", age: 18, starship: :enterprise)

		a.name.should == "john"
		a.address.should == "vulcano"
		a.age.should == 18
		a.starship.should == :enterprise

		a.name = "b"
		a.address = "Earth"
		a.age = 120
		a.starship = :yamato

		a.name.should == "b"
		a.address.should == "Earth"
		a.age.should == 120
		a.starship.should == :yamato
	end
end	

describe RoleTest::Enemy do
	it "should create a new instance" do
		RoleTest::Enemy.new( name: "john", address: "vulcano", complement: 1, weapons: :phaser)
	end

	it "should has a name" do
		a = RoleTest::Enemy.new(name: "john", address: "vulcano", complement: 1, weapons: :phaser)

		a.name.should == "john"
		a.address.should == "vulcano"
		a.weapons.should == :phaser
		a.complement.should == 1

		a.name = "b"
		a.address = "Earth"
		a.weapons = :disruptor
		a.complement = 7

		a.name.should == "b"
		a.address.should == "Earth"
		a.weapons.should == :disruptor
		a.complement.should == 7
	end
end	

describe RoleTest::AlienX do
	it "should create a new instance" do
		RoleTest::AlienX.new( name: "john", address: "vulcano", race: :klingon, x: 0)
	end

	it "should has a name" do
		a = RoleTest::AlienX.new(name: "john", address: "vulcano", race: :klingon, x: 0)

		a.name.should == "john"
		a.address.should == "vulcano"
		a.race.should == :klingon
		a.x.should == 0

		a.name = "b"
		a.address = "Earth"
		a.race = :borg
		a.x = -1

		a.name.should == "b"
		a.address.should == "Earth"
		a.race.should == :borg
		a.x.should == -1
	end
end	