#!/usr/bin/python3

import os
import subprocess
import shutil

magickPath = os.path.expanduser('~/imageMagick/bin/magick')

source2x3 = "./input/2x3"
files2x3 = os.listdir(source2x3)
source4x3 = "./input/4x3"
files4x3 = os.listdir(source4x3)
source3x4 = "./input/3x4"
files3x4 = os.listdir(source3x4)
source16x9 = "./input/16x9"
files16x9 = os.listdir(source16x9)
sourceGooglePlay = "./input/GooglePlay"
filesGooglePlay = os.listdir(sourceGooglePlay)

target = "./output"
os.makedirs(target, exist_ok=True)
targetPrimary = "./output/PrimaryKeyArt"
os.makedirs(targetPrimary, exist_ok=True)
targetAlternative = "./output/AlternativeKeyArt"
os.makedirs(targetAlternative, exist_ok=True)
targetAmazonPrime = "./output/AmazonPrime"
os.makedirs(targetAmazonPrime, exist_ok=True)
targetAppleTv = "./output/AppleTV"
os.makedirs(targetAppleTv, exist_ok=True)
targetHulu = "./output/Hulu"
os.makedirs(targetHulu, exist_ok=True)
targetNetflix = "./output/Netflix"
os.makedirs(targetNetflix, exist_ok=True)
targetOlympusat = "./output/Olympusat"
os.makedirs(targetOlympusat, exist_ok=True)
targetRoku = "./output/Roku"
os.makedirs(targetRoku, exist_ok=True)
targetTitleCard = "./output/TitleCard"
os.makedirs(targetTitleCard, exist_ok=True)
targetYouTubeMovie = "./output/YouTubeMovie"
os.makedirs(targetYouTubeMovie, exist_ok=True)
targetGooglePlay = "./output/GooglePlay"
os.makedirs(targetGooglePlay, exist_ok=True)

for filename in files2x3:
    inputFilePath = os.path.join(source2x3, filename)
    outputFilename800 = os.path.splitext(filename)[0] + '_800x1200.jpg'
    outputFilePath800 = os.path.join(target, outputFilename800)
    outputFilename1080 = os.path.splitext(filename)[0] + '_1080x1620.jpg'
    outputFilePath1080 = os.path.join(target, outputFilename1080)
    outputFilename2000 = os.path.splitext(filename)[0] + '_2000x3000.jpg'
    outputFilePath2000 = os.path.join(target, outputFilename2000)
    outputFilename4320 = os.path.splitext(filename)[0] + '_4320x6480.jpg'
    outputFilePath4320 = os.path.join(target, outputFilename4320)
    if os.path.isfile(inputFilePath):
        print(f"Processing: {inputFilePath}")
        command = [magickPath, inputFilePath, '-resize', '800x1200', outputFilePath800]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath800}")
        shutil.copy2(outputFilePath800, targetOlympusat)
        os.remove(outputFilePath800)
        command = [magickPath, inputFilePath, '-resize', '1080x1620', outputFilePath1080]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1080}")
        shutil.copy2(outputFilePath1080, targetOlympusat)
        os.remove(outputFilePath1080)
        command = [magickPath, inputFilePath, '-resize', '2000x3000', outputFilePath2000]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath2000}")
        shutil.copy2(outputFilePath2000, targetNetflix)
        shutil.copy2(outputFilePath2000, targetPrimary)
        os.remove(outputFilePath2000)
        command = [magickPath, inputFilePath, '-resize', '4320x6480', outputFilePath4320]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath4320}")
        shutil.copy2(outputFilePath4320, targetAppleTv)
        os.remove(outputFilePath4320)

for filename in files4x3:
    inputFilePath = os.path.join(source4x3, filename)
    outputFilename1600 = os.path.splitext(filename)[0] + '_1600x1200.jpg'
    outputFilePath1600 = os.path.join(target, outputFilename1600)
    if os.path.isfile(inputFilePath):
        print(f"Processing: {inputFilePath}")
        command = [magickPath, inputFilePath, '-resize', '1600x1200', outputFilePath1600]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1600}")
        shutil.copy2(outputFilePath1600, targetOlympusat)
        os.remove(outputFilePath1600)

for filename in files3x4:
    inputFilePath = os.path.join(source3x4, filename)
    outputFilename1200 = os.path.splitext(filename)[0] + '_1200x1600.jpg'
    outputFilePath1200 = os.path.join(target, outputFilename1200)
    if os.path.isfile(inputFilePath):
        print(f"Processing: {inputFilePath}")
        command = [magickPath, inputFilePath, '-resize', '1200x1600', outputFilePath1200]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1200}")
        shutil.copy2(outputFilePath1200, targetAmazonPrime)
        os.remove(outputFilePath1200)

for filename in files16x9:
    inputFilePath = os.path.join(source16x9, filename)
    outputFilename450 = os.path.splitext(filename)[0] + '_800x450.jpg'
    outputFilePath450 = os.path.join(target, outputFilename450)
    outputFilename1280 = os.path.splitext(filename)[0] + '_1280x720.jpg'
    outputFilePath1280 = os.path.join(target, outputFilename1280)
    outputFilename1920 = os.path.splitext(filename)[0] + '_1920x1080.jpg'
    outputFilePath1920 = os.path.join(target, outputFilename1920)
    outputFilename2560 = os.path.splitext(filename)[0] + '_2560x1440.jpg'
    outputFilePath2560 = os.path.join(target, outputFilename2560)
    outputFilename3840 = os.path.splitext(filename)[0] + '_3840x2160.jpg'
    outputFilePath3840 = os.path.join(target, outputFilename3840)
    if os.path.isfile(inputFilePath):
        print(f"Processing: {inputFilePath}")
        command = [magickPath, inputFilePath, '-resize', '800x450', outputFilePath450]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath450}")
        shutil.copy2(outputFilePath450, targetRoku)
        os.remove(outputFilePath450)
        command = [magickPath, inputFilePath, '-resize', '1280x720', outputFilePath1280]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1280}")
        shutil.copy2(outputFilePath1280, targetYouTubeMovie)
        os.remove(outputFilePath1280)
        command = [magickPath, inputFilePath, '-resize', '1920x1080', outputFilePath1920]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1920}")
        shutil.copy2(outputFilePath1920, targetAlternative)
        shutil.copy2(outputFilePath1920, targetHulu)
        os.remove(outputFilePath1920)
        command = [magickPath, inputFilePath, '-resize', '2560x1440', outputFilePath2560]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath2560}")
        shutil.copy2(outputFilePath2560, targetOlympusat)
        os.remove(outputFilePath2560)
        command = [magickPath, inputFilePath, '-resize', '3840x2160', outputFilePath3840]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath3840}")
        shutil.copy2(outputFilePath3840, targetTitleCard)
        os.remove(outputFilePath3840)

for filename in filesGooglePlay:
    inputFilePath = os.path.join(sourceGooglePlay, filename)
    outputFilename1024 = os.path.splitext(filename)[0] + '_1024x500.jpg'
    outputFilePath1024 = os.path.join(target, outputFilename1024)
    if os.path.isfile(inputFilePath):
        print(f"Processing: {inputFilePath}")
        command = [magickPath, inputFilePath, '-resize', '1024x500', outputFilePath1024]
        subprocess.run(command, check=True)
        print(f"Resized {inputFilePath} → {outputFilePath1024}")
        shutil.copy2(outputFilePath1024, targetGooglePlay)
        os.remove(outputFilePath1024)