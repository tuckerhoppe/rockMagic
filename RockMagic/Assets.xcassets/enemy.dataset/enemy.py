import pygame

##Draws enemy, stores enemy health, Control getting hit, moving AI
class Enemy(object):
  #BadGuy images
  walkRight = [pygame.image.load('badGuyR1.png'), pygame.image.load('badGuyR2.png'),pygame.image.load('badGuyR3.png'),pygame.image.load('badGuyR4.png'),pygame.image.load('badGuyR5.png'), pygame.image.load('badGuyR3.png'),pygame.image.load('badGuyR3.png'),pygame.image.load('badGuyR4.png'),pygame.image.load('badGuyR5.png')]
  badLaunched = pygame.image.load('badGuyLaunched.png')
  badAttack = pygame.image.load('badGuyAttack.png')

  def __init__(self, x, y, end):
    self.x = x
    self.y = y
    self.end = end
    self.path = [self.x, self.end]
    self.walkCount = 0
    self.attackCount = 0
    self.vel = 3
    self.hitBox = (self.x, self.y,38 , 60)
    self.airCount = 10
    self.launched = False
    self.attacking = False
    self.healthPoints = 50
    self.right = True
    self.upgradeWorth = 1

    self.sidewaysLaunchDistance = 10
    self.launchHeight = 10
    self.rightAtLaunch = True
    
    
  def draw(self, window, earthBender, keys):
    if self.walkCount + 1 >= 27:
      self.walkCount = 0
    #hitBox
    self.hitBox = (self.x , self.y, 38, 60)
    #pygame.draw.rect(window, (255, 0, 0), self.hitBox, 2)
    pygame.draw.rect(window, (255, 0, 0), (self.x, self.y - 10,round(self.healthPoints),5), 0)
    
    ##Draw the correct image of enemy based on enemy is doing
    if not(self.launched):
      self.airCount = 10
      if not(self.attacking): ##Normal Walking
        self.move(window, earthBender)
        if self.vel > 0:
          window.blit(self.walkRight[int(self.walkCount / 3)], (self.x, self.y))
          self.walkCount += 1
          self.right = True
        else:
          window.blit(pygame.transform.flip(self.walkRight[int(self.walkCount/3)],True,False), (round(self.x - 20),round(self.y)))
          self.walkCount += 1
          self.right = False
      else: ##Attacking Code
        self.attackCount += 1 
        if self.attackCount == 15:
          self.attackCount = 0
        if self.attackCount >= 11:
          if self.right:
            window.blit(self.badAttack, (self.x, self.y))
          else:
            window.blit(pygame.transform.flip(self.badAttack,True,False), (round(self.x - 40),round(self.y)))
        else:
          if self.right:
            window.blit(self.walkRight[int(self.walkCount / 3)], (self.x, self.y))
          else:
            window.blit(pygame.transform.flip(self.walkRight[int(self.walkCount/3)],True,False), (round(self.x - 20),round(self.y)))
    else: #Launch through the Air
      if not(self.rightAtLaunch): 
        window.blit(self.badLaunched, (self.x, self.y))
      else:
        window.blit(pygame.transform.flip(self.badLaunched,True,False), (round(self.x - 20),round(self.y)))
      if self.airCount >= -10:
        if self.rightAtLaunch:
          self.x += self.sidewaysLaunchDistance
        else:
          self.x -= self.sidewaysLaunchDistance
        neg = 1
        if self.airCount < 0:
          neg = -1
        if self.airCount <= 10:
          self.y -= round((self.airCount ** 2) /self.launchHeight * neg)
        self.airCount -= 1
        
      else:
        self.launched = False
        self.airCount = 10
        self.sidewaysLaunchDistance = 10
        self.launchHeight = 10


    ##Move with Background
    self.path = [self.x, self.end]
    if keys[pygame.K_LEFT] and earthBender.x <= earthBender.speed + 200 and not(earthBender.halt):
      self.x += earthBender.speed
      self.end += earthBender.speed
    elif keys[pygame.K_RIGHT] and earthBender.x >= 550 - earthBender.width - earthBender.speed and not(earthBender.halt):
      self.x -= earthBender.speed
      self.end -= earthBender.speed

  def move(self, window, earthBender):
    ##Move Enemy Towards enemy AI
    if earthBender.x < self.x:
      if self.vel > 0:
        self.vel = self.vel * -1
    else:
      if self.vel < 0:
        self.vel = self.vel * -1
    self.x += self.vel
    
  def hit(self, hitUp, earthBender):
    ##When Enemy gets hit by Boulder
    self.healthPoints -= 10
    self.launched = True
    self.rightAtLaunch = earthBender.right
    if hitUp:
      self.launchHeight = 3
      self.sidewaysLaunchDistance = 5

  def quickHit(self):
    ##When Enemy gets hit by rock
    self.healthPoints -= 3
    
  def inAir(self):
    ##I don't think this does anything
    self.x += 10
    if self.airCount <= 10:
      neg = 1
    else:
      neg = -1
    
    self.y -= self.airCount * neg