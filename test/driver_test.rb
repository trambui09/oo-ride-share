require_relative 'test_helper'

describe "Driver class" do
  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Test Driver",
        vin: "12345678901234567",
        status: :AVAILABLE
      )
    end

    it "is an instance of Driver" do
      expect(@driver).must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad ID" do
      expect { RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133") }.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "") }.must_raise ArgumentError
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums") }.must_raise ArgumentError
    end

    it "has a default status of :AVAILABLE" do
      expect(RideShare::Driver.new(id: 100, name: "George", vin: "12345678901234567").status).must_equal :AVAILABLE
    end

    #added test
    it "throws an argument error with invalid status" do
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133", status: :BOOP)}.must_raise ArgumentError
    end

    it "sets driven trips to an empty array if not provided" do
      expect(@driver.trips).must_be_kind_of Array
      expect(@driver.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vin, :status, :trips].each do |prop|
        expect(@driver).must_respond_to prop
      end

      expect(@driver.id).must_be_kind_of Integer
      expect(@driver.name).must_be_kind_of String
      expect(@driver.vin).must_be_kind_of String
      expect(@driver.status).must_be_kind_of Symbol
    end
  end

  describe "add_trip method" do
    before do
      pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640"
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678"
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: pass,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2018, 8, 9),
        rating: 5
      )
    end

    it "adds the trip" do
      expect(@driver.trips).wont_include @trip
      previous = @driver.trips.length

      @driver.add_trip(@trip)

      expect(@driver.trips).must_include @trip
      expect(@driver.trips.length).must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 8),
        rating: 5
      )
      @driver.add_trip(@trip)
    end

    it "returns a float" do
      expect(@driver.average_rating).must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      expect(average).must_be :>=, 1.0
      expect(average).must_be :<=, 5.0
    end

    it "returns zero if no driven trips" do
      driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ"
      )
      expect(driver.average_rating).must_equal 0
    end

    it "correctly calculates the average rating" do
      trip2 = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 9),
        rating: 1
      )
      @driver.add_trip(trip2)

      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end

    #wave 3
    it "ignores in-progress trips" do
      passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: []
      )
      new_trip = RideShare::Trip.new(
          # what should the id of this trip be?
          id: 25,
          passenger: passenger,
          passenger_id: passenger.id,
          start_time: Time.now,
          end_time: nil,
          cost: nil,
          rating: nil,
          driver_id: 4,
          )
      @driver.add_trip(@trip)
      @driver.add_trip(new_trip)

      expect(@driver.average_rating).must_equal 5

    end
  end

  describe "total_revenue" do
    before do
      #FEE = 1.65
      @driver = RideShare::Driver.new(
          id: 54,
          name: "Rogers Bartell IV",
          vin: "1C9EVBRM0YBC564DZ"
      )
      @trip_1 = RideShare::Trip.new(
          id: 8,
          driver: @driver,
          passenger_id: 3,
          start_time: Time.new(2016, 8, 8),
          end_time: Time.new(2016, 8, 8),
          rating: 5,
          cost: 15.0,
      )
      @trip_2 = RideShare::Trip.new(
          id: 9,
          driver: @driver,
          passenger_id: 4,
          start_time: Time.new(2016, 9, 8),
          end_time: Time.new(2016, 9, 9),
          rating: 5,
          cost: 10,
          )
      @passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: []
      )
      #@driver.add_trip(trip_1)
    end
    # You add tests for the total_revenue method
    it "returns an float " do
      @driver.add_trip(@trip_1)

      #assert
      expect(@driver.total_revenue).must_be_kind_of Float
    end

    it "correctly get the total for a single trip" do
      driver = RideShare::Driver.new(
          id: 54,
          name: "Rogers Bartell IV",
          vin: "1C9EVBRM0YBC564DZ"
      )
      trip = RideShare::Trip.new(
          id: 8,
          driver: @driver,
          passenger_id: 3,
          start_time: Time.new(2016, 8, 8),
          end_time: Time.new(2016, 8, 8),
          rating: 5,
          cost: 1,
          )
      driver.add_trip(trip)

      expect(driver.total_revenue).must_equal 0


    end

    it "correctly calculates the total revenue of two trips" do
      #arrange and act
      @driver.add_trip(@trip_1)
      @driver.add_trip(@trip_2)

      #assert
      expect(@driver.total_revenue).must_be_close_to 17.36, 0.01

    end

    it "returns zero if no driven trips" do
      # assert
      expect(@driver.total_revenue).must_equal 0

    end

    it "ignores in-progress trips" do

      new_trip = RideShare::Trip.new(
          # what should the id of this trip be?
          id: 25,
          passenger: @passenger,
          passenger_id: @passenger.id,
          start_time: Time.now,
          end_time: nil,
          cost: nil,
          rating: nil,
          driver_id: 4,
          )

      @driver.add_trip(@trip_1)
      @driver.add_trip(new_trip)

      expect(@driver.total_revenue).must_be_close_to 10.68, 0.1

    end

  end
  # tests for wave 3: change_status
  describe "change status" do
    before do
      @driver = RideShare::Driver.new(
          id: 60,
          name: "Rogers Bartell IV",
          vin: "1C9EVBRM0YBC564DZ",
          status: :AVAILABLE
      )
    end

    it "change the status of driver" do
      #act and assert
      expect(@driver.status).must_equal :AVAILABLE

      expect(@driver.change_status).must_equal :UNAVAILABLE

    end
  end

end
