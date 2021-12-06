#!/usr/bin/env perl -w
use Cwd;

sub pixVideos {
	my($dir) = @_;

	my(@pixExtensions) = ('jpg','jpeg','png','gif');
	my(@videoExtensions) = ('mp4','mpeg','avi','mov', 'm4v');

	my($rawDir) = "$dir/raw";
	my($pixDir) = "$dir/pix";
	my($videoDir) = "$dir/video";

	mkdir("$pixDir", 0755) unless -d "$pixDir $!";
	mkdir("$videoDir", 0755) unless -d "$videoDir $!";
	
	if(-d $rawDir) {
		opendir(DIR, $rawDir);
		while($filename = readdir(DIR)){
			moveFiles($rawDir, $pixDir, $filename, \@pixExtensions);
			moveFiles($rawDir, $videoDir, $filename, \@videoExtensions);
		}
		closedir(DIR);
	}
	else {
		print ("$rawDir does not exist.");
	}
}

sub moveFiles {
	my($oldDir, $newDir, $filename, $extensions) = @_;

	print("oldDir: $oldDir, newDir: $newDir, filename: $filename\n");

	foreach(@$extensions) {
		if($filename =~ /$_$/i) {
			if(! -e "$newDir/$filename") {
				link("$oldDir/$filename", "$newDir/$filename");
			}
			else {
				my($name) = substr($file, 0, rindex($filename, '.'));
				my($ext) = substr($file, rindex($filename, '.') + 1);
				my($count) = 0;

				while(-e "${newDir}/${name}_${count}.${ext}") {
					$count++;
				}

				link("$oldDir/$filename", "${newDir}/${name}_${count}.${ext}");
			}
			unlink("$oldDir/$filename");
		}
	}
}

sub sortDir {
	my($dir) = @_;
	chomp $dir;
	opendir(DIR, $dir) || die "$dir is not a directory";
	while($filename = readdir(DIR)){
		if($filename =~ /^(IMG|VID)/) {
			($prefix, $date, $file) = split(/_/, $filename);
			makeDir($dir, $date, $filename, 1);
		}
		elsif($filename =~ /^2/) {
			($date, $file) = split(/_/, $filename);
			makeDir($dir, $date, $filename, 0);
		}
		elsif($filename =~ /^DSCF/) {
			makeDir($dir, 'dscf', $filename, 0);
		}
		elsif($filename =~ /^MVI/) {
			makeDir($dir, 'mvi', $filename, 0);
		}
		else {
			makeDir($dir, 'other', $filename, 0);
		}
	}
	closedir(DIR);
}

sub makeDir {
	my($dir, $folder, $filename, $hasPrefix) = @_;
	my $newFolder = "$dir/$folder";

	if(! -d "$newFolder") {
		print("creating: $newFolder\n");
		mkdir("$newFolder", 0755)|| die "can't create $newFolder" unless -d "$newFolder $!";
	}

	my $oldFilename = "$dir/$filename";
	my $newFilename;

	if($hasPrefix) {
		$newFilename = "$newFolder/" . substr($filename, 4);
	}
	else {
		$newFilename = "$newFolder/$filename";
	}

	if(-f "$oldFilename") {
		if(! -e $newFilename) {
			link($oldFilename, $newFilename);
			print "moving: $oldFilename to $newFilename.\n";
		}
		else {
			print "$newFilename already exists.\n";
		}
		unlink("$oldFilename");
	}
	else {
		print STDERR "$oldFilename is not a file\n";
	}
}

my $dir = getcwd;
pixVideos($dir);
sortDir "$dir/pix";
sortDir "$dir/video";
