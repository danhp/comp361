.PHONY: test clean

test:
	xctool test -project Warfare/Warfare.xcodeproj -scheme warfare -sdk iphonesimulator

clean:
	xctool clean -project Warfare/Warfare.xcodeproj -scheme warfare

