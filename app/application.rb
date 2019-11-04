require 'opal'
require 'native'
require 'js'

class Application
  WIDTH = 800
  HEIGHT = 600

  def initialize
    @game = JS.new(`Phaser.Game`, config)
    @score = 0
  end

  private

  def config
    {
      type: `Phaser.AUTO`,
      width: WIDTH,
      height: HEIGHT,
      physics: {
        default: 'arcade',
        arcade: {
          gravity: { y: 300 },
          debug: false
        }
      },
      scene: {
        preload: preload,
        create: create,
        update: update
      }
    }.to_n
  end

  def preload
    lambda do
      this = Native(`this`)
      this.load.image('sky', 'assets/sky.png')
      this.load.image('ground', 'assets/platform.png')
      this.load.image('star', 'assets/star.png')
      this.load.image('bomb', 'assets/bomb.png')
      this.load.spritesheet(
        'dude',
        'assets/dude.png',
        { frameWidth: 32, frameHeight: 48 }.to_n
      )
    end
  end

  def create
    lambda do
      this = Native(`this`)
      this.add.image(400, 300, 'sky')

      @platforms = this.physics.add.staticGroup()
      @platforms.create(400, 568, 'ground').setScale(2).refreshBody()
      @platforms.create(600, 400, 'ground')
      @platforms.create(50, 250, 'ground')
      @platforms.create(750, 220, 'ground')

      @player = this.physics.add.sprite(100, 450, 'dude')
      @player.setBounce(0.2)
      @player.setCollideWorldBounds(true)

      this.anims.create({
        key: 'left',
        frames: this.anims.generateFrameNumbers('dude', { start: 0, end: 3 }.to_n),
        framerate: 10,
        repeat: -1
      }.to_n)

      this.anims.create({
        key: 'right',
        frames: this.anims.generateFrameNumbers('dude', { start: 5, end: 8 }.to_n),
        framerate: 10,
        repeat: -1
      }.to_n)

      this.anims.create({
        key: 'turn',
        frames: [ { key: 'dude', frame: 4 } ],
        frameRate: 20
      }.to_n)

      @stars = this.physics.add.group({
        key: 'star',
        repeat: 11,
        setXY: { x: 12, y: 0, stepX: 70 }
      }.to_n)

      this.physics.add.collider(@player, @platforms)

      @stars.children.iterate(lambda do |star|
        star.JS.setBounceY(Native(`Phaser.Math`).FloatBetween(0.4, 0.8))
      end)

      this.physics.add.collider(@stars, @platforms)

      this.physics.add.collider(@player, @stars, ->(player, star) {
        star.JS.disableBody(true, true)

        @score += 10
        @score_text.setText("Score: #{@score}")

        if @stars.countActive(true) == 0
          @stars.children.iterate(lambda do |star|
            star.JS.enableBody(true, star.JS[:x], 0, true, true)
          end)

          math = Native(`Phaser.Math`)
          x = @player.x < 400 ? math.Between(400, 800) : math.Between(0, 400)

          bomb = @bombs.create(x, 16, 'bomb')
          bomb.setBounce(1)
          bomb.setCollideWorldBounds(true)
          bomb.setVelocity(math.Between(-200, 200), 20)
          bomb.allowGravity(false)
        end
      }, nil, this)

      @bombs = this.physics.add.group()

      this.physics.add.collider(@bombs, @platforms)
      this.physics.add.collider(@player, @bombs, ->(player, bomb) {
        this.physics.pause
        @player.setTint('0xff0000')
        @player.anims.play('turn')
        @finished = true
        this.add.text(50, 200, 'GAME OVER', { fontSize: '128px', fill: 'red', align: 'center' }.to_n)
      }, nil, this)

      @score_text = this.add.text(16, 16, 'Score: 0', { fontSize: '32px', fill: '#000' }.to_n)

    end
  end

  def update
    lambda do
      unless @finished
        cursors = Native(`this`).input.keyboard.createCursorKeys()

        if cursors.left.isDown
          @player.setVelocityX(-160)
          @player.anims.play('left', true)
        elsif cursors.right.isDown
          @player.setVelocityX(160)
          @player.anims.play('right', true)
        else
          @player.setVelocityX(0)
          @player.anims.play('turn')
        end

        if cursors.up.isDown && @player.body.touching.down
          @player.setVelocityY(-330)
        end
      end
    end
  end
end

