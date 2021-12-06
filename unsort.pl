#!/usr/bin/env perl -w
use Cwd;

sub undoAll {
	my($dir) = @_;
	my($rawDir) = "$dir/raw";
	my($pixDir) = "$dir/pix";
	my($videoDir) = "$dir/video";
	
	if(! -d $rawDir) {
		mkdir("$rawDir", 0755)|| die "can't create $rawDir $!";
	}

	undoOne($pixDir, $rawDir);
	undoOne($videoDir, $rawDir);
}

sub undoOne {
	my($targetDir, $rawDir) = @_;
	print("targetDir = $targetDir, rawDir = $rawDir\n");

	if(-d $targetDir) {
		print("1: $targetDir\n");
		opendir(DIR1, $targetDir);
		while($filename1 = readdir(DIR1)){
			if(-d "$targetDir/$filename1") {
				if($filename1 =~ /^[A-Za-z0-9]+/) {
					print("2: $targetDir/$filename1\n");
					opendir(DIR2, "$targetDir/$filename1");
					while($filename2 = readdir(DIR2)) {
						if($filename2 =~ /^[A-Za-z0-9]+/) {
							print("3: $targetDir/$filename1/$filename2, $rawDir/$filename2\n");
							link("$targetDir/$filename1/$filename2", "$rawDir/$filename2");
							unlink("$targetDir/$filename1/$filename2");
						}
					}
					closedir(DIR2);
					rmdir("$targetDir/$filename1");
				}
			}
			elsif(-f "$targetDir/$filename1") {
				if($filename1 =~ /^[A-Za-z0-9]+/) {
					print("4: $targetDir/$filename1, $rawDir/$filename1\n");
					link("$targetDir/$filename1", "$rawDir/$filename1");
					rmdir("$targetDir/$filename1");
				}
			}
		}
		closedir(DIR1);
	}
}

my $dir = getcwd;
undoAll($dir);
