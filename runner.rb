require 'csv'

class Coords
  def initialize
    p "init"
    @examples = eval(IO.read('example.txt').gsub('\n', '').gsub('\r', ''))
    @result = []
  end

  def result
    @result
  end

  def examples
    @examples
  end

  def run
    p examples
    p "generate examples"
    
    self.examples.each do |example|
      unless example[:type] == 0
        time_const = Time.now.to_i        
        example[:coords].each_with_index do |coord, index|
          time_etalon = time_const + rand(100)
          if index == 0
            coord[:time] = time_etalon
            time_etalon = coord[:time]
          else            
            # от 60 до 90 км/ч
            # скорость м/c
            speed = rand(16..25)        
            pre_coord = example[:coords][index-1]
            # дистанция в метрах
            last_distance = Coords.distance(pre_coord[:lat], pre_coord[:lon], coord[:lat], coord[:lon])
            # разница во времени в секундах
            alpha_time = last_distance/speed
            coord[:time] = time_etalon + alpha_time
            time_etalon = coord[:time]
          end
        end
      end
      self.result << example
    end

    p self.result
    File.open('output_data.txt', 'w'){ |file| file.write self.result.to_s }   
    if self.result.size > 0      
      CSV.open("output_data.csv", "w", {:col_sep => ";"}) do |csv|
        csv << ["imei", "time", "lat", "lon"]
        self.result.each do |item|
          imei = rand(99999..999999)
          item[:coords].each do |coord|
            csv << [imei, coord[:time], coord[:lat], coord[:lon]]
          end
        end
      end
    end
  end

  def self.distance(lat1, lon1, lat2, lon2)
    d2r = 0.017453; # Eiinoaioaaeyi?aia?aciaaieya?aaoniaa?aaeaiu
    r2d = 57.295781; # Eiinoaioaaeyi?aia?aciaaiey?aaeaiaa?aaonu
    a = 6378137.0; # Iniiaiuaiieoine
    b = 6356752.314245; # Iainiiaiuaiieoine
    e2 = 0.006739496742337; # Eaaa?aoyenoaio?e?iinoeyeeeinieaa
    f = 0.003352810664747; # Au?aaieaaieayeeeinieaa

    # Au?eneyai ?acieoo ia?ao aaoiy aieaioaie e oe?ioaie e iieo?aai n?aai?? oe?ioo
    fdLambda = (lon1 - lon2) * d2r;
    fdPhi = (lat1 - lat2) * d2r;
    fPhimean = ((lat1 + lat2) / 2.0) * d2r;

    # Au?eneyai ia?eaeaiiua e iiia?a?iua ?aaeonu e?eaeciu n?aaiae oe?iou
    fTemp = 1 - e2 * (Math.sin(fPhimean)**2);
    fRho = (a * (1 - e2)) / (fTemp**1.5);
    fNu = a / (Math.sqrt(1 - e2 * (Math.sin(fPhimean) * Math.sin(fPhimean))));

    fz = Math.sqrt((Math.sin(fdPhi / 2.0)**2) + Math.cos(lat2 * d2r) * Math.cos(lat1 * d2r) *
      (Math.sin(fdLambda / 2.0)**2));

    fz = 2 * Math.asin(fz);

    fAlpha = Math.cos(lat2 * d2r) * Math.sin(fdLambda) * 1 / Math.sin(fz);
    fAlpha = Math.asin(fAlpha);

    fR = (fRho * fNu) / ((fRho * (Math.sin(fAlpha)**2)) + (fNu *
    (Math.cos(fAlpha)**2)));

    distance = (fz * fR);
    return distance;
  end
end


p "ruby started"
coords = Coords.new
coords.run
