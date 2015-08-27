Prawn::ManualBuilder::Example.generate 'readme.pdf' do
  package 'readme' do |p|
    p.name = 'Readme'

    p.intro do
    end

    p.section 'Single series' do |s|
      s.example '01-basic'
      s.example '02-type-point'
      s.example '03-type-line'
      s.example '04-color'
      s.example '05-gridlines'
      s.example '06-ticks'
      s.example '07-baseline'
      s.example '08-every'
      s.example '09-legend'
      s.example '10-legend-offset'
      s.example '11-format'
      s.example '12-labels'
      s.example '13-border'
      s.example '14-height'
      s.example '15-multiple-columns'
      s.example '16-multiple-stacks'
      s.example '17-singular-options'
      s.example '18-plural-options'
      s.example '19-two-axis'
    end
  end
end