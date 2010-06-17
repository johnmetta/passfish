module WheelOfFortune
  
  def spin arr, spin
    begin
      spin.each do |sp|
        (0...sp).each do
          arr << arr.shift
        end
      end
    rescue
      (0..spin).each do
        arr << arr.shift
      end
    end
    arr
  end

end    
