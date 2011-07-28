//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TravelEditViewController.h"
#import "Currency.h"
#import "TravelNotManaged.h"
#import "EditableTableViewCell.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "Country.h"
#import "GenericSelectViewController.h"
#import "ParticipantHelper.h"
#import "CountryCell.h"
#import "TextEditViewController.h"
#import "AlignedStyle2Cell.h"

static NSIndexPath *_countryIndexPath;
static NSIndexPath *_cityIndexPath;
static NSIndexPath *_descriptionIndexPath;
static NSIndexPath *_currenciesIndexPath;

@interface TravelEditViewController ()
- (void)startLocating;
- (void)initIndexPaths;
- (void)updateAndFlash:(UIViewController *)viewController;
@end

@implementation TravelEditViewController

@synthesize name=_name, travel=_travel, country=_country, currencies=_currencies, city=_city;

@synthesize locManager=_locManager;


- (id) initInManagedObjectContext:(NSManagedObjectContext *)context {
    
    self = [self initInManagedObjectContext:context withTravel:nil];
    return self;
}

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        _context = context;
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.delegate = self;
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        if (self.travel) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
        } else {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
        }
        
        self.title = @"Add Trip";  
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        if (!travel) {
            
            self.currencies = [NSArray arrayWithObject:[ReiseabrechnungAppDelegate defaultsObject:context].homeCurrency];
            self.name = @"";
            self.city = @"";
            self.country = nil;
            
        } else {
            
            self.travel = travel;
            self.name = travel.name;
            self.city = travel.city;
            self.country = travel.country;
            self.currencies = [travel.currencies allObjects];
            
            // init location manager
            self.locManager = [[[CLLocationManager alloc] init] autorelease];
            if (![CLLocationManager locationServicesEnabled]) {
                NSLog(@"User has opted out of location services");
            }
            
            self.locManager.delegate = self;
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            self.locManager.distanceFilter = 5.0f; // in meters
            
            if (!self.country) {
                [self startLocating];
            }
        }
    }
    return self;
}

- (void)initIndexPaths {
    _descriptionIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _countryIndexPath = [[NSIndexPath indexPathForRow:0 inSection:1] retain];
    _cityIndexPath = [[NSIndexPath indexPathForRow:1 inSection:1] retain];
    _currenciesIndexPath = [[NSIndexPath indexPathForRow:2 inSection:1] retain];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 3;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_countryIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Country";
        if (self.country) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.country.name];
            if (self.country.image) {
                NSString *pathCountryPlist =[[NSBundle mainBundle] pathForResource:self.country.image ofType:@""];
                cell.imageView.image = [UIImage imageWithContentsOfFile:pathCountryPlist];                       
            }
        }
        
    } else if ([indexPath isEqual:_cityIndexPath]) {
                
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = @"City/State";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.city;

    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.textLabel.text = @"Description";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.name;
        
    } else if ([indexPath isEqual:_currenciesIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Foreign";
        
        NSString *currenciesString = @"";
        const unichar cr = '\n';
        NSString *singleCR = [NSString stringWithCharacters:&cr length:1];
        for (Currency *currency in self.currencies) {
            currenciesString = [[currenciesString stringByAppendingString:currency.name] stringByAppendingString:singleCR];
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n", [currenciesString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        cell.detailTextLabel.numberOfLines = 0;

    } else {
        NSLog(@"no indexpath cell found for %@ ", indexPath);
    }
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] -1 ) {
        //[UIFactory addShadowToView:cell];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:_currenciesIndexPath] && [self.currencies count] > 1) {
        return 40 + (([self.currencies count]-1) * 19.5);
    } else {
        return [UIFactory defaultCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_countryIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                                         withMultiSelection:NO
                                                                                                           withFetchRequest:_fetchRequest 
                                                                                                             withSectionKey:@"uppercaseFirstLetterOfName"
                                                                                                        withSelectedObjects:[NSArray arrayWithObjects:self.country, nil]
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCountry:)];
        selectViewController.imageKey = @"image";
        selectViewController.searchKey = @"name";
        
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
        
    } else if ([indexPath isEqual:_cityIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.city target:self selector:@selector(selectCity:)]; 
        textEditViewController.title = @"City";
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];            
        
        
    } else if ([indexPath isEqual:_descriptionIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.name target:self selector:@selector(selectName:)]; 
        textEditViewController.title = @"Description";
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];
        
    } else if ([indexPath isEqual:_currenciesIndexPath]) {
        
        NSFetchRequest *_fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext: _context];
        _fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]; 
        
        GenericSelectViewController *selectViewController = [[GenericSelectViewController alloc] initInManagedObjectContext:_context
                                                                                                         withMultiSelection:YES
                                                                                                           withFetchRequest:_fetchRequest
                                                                                                             withSectionKey:@"uppercaseFirstLetterOfName"
                                                                                                        withSelectedObjects:self.currencies
                                                                                                                     target:self
                                                                                                                     action:@selector(selectCurrencies:)];
        selectViewController.searchKey = @"name";
        [self.navigationController pushViewController:selectViewController animated:YES];
        [selectViewController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:self];
}

- (void)updateAndFlash:(UIViewController *)viewController {
    
    if (viewController == self) {
        
        [self.tableView beginUpdates];
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
        
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];                  
        }
        [_cellsToReloadAndFlash removeAllObjects];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.travel && _isFirstView) {
        [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
        [self updateAndFlash:self];
        _isFirstView = NO;
    }
}

- (void)selectCurrencies:(NSArray *)newCurrencies {
    
    if (![newCurrencies isEqual:self.currencies]) {
        self.currencies = newCurrencies;
        [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
    }
}

- (void)selectCountry:(Country *)newCountry {
    
    if (![newCountry isEqual:self.country]) {
        
        self.country = newCountry;
        self.currencies = [newCountry.currencies allObjects];
        
        [_cellsToReloadAndFlash addObject:_countryIndexPath];
        [_cellsToReloadAndFlash addObject:_currenciesIndexPath];
    }
}

- (void)selectName:(NSString *)newName {
    
    if (![newName isEqualToString:self.name]) {
        self.name = newName;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_descriptionIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (!self.country && [newName length] > 0) {
            NSFetchRequest *req = [[NSFetchRequest alloc] init];
            req.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
            req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            NSArray *countrySet = [_context executeFetchRequest:req error:nil];
            [req release];
            
            NSArray *nameComponents = [[[newName lowercaseString] componentsSeparatedByString:@" "] arrayByAddingObject:[newName lowercaseString]];
            for (NSString* nameComponent in nameComponents) {
                if ([nameComponent length] >= 3) {
                    for (Country* country in countrySet) {
                        if ([nameComponent isEqual:[country.name lowercaseString]]) {
                            [self selectCountry:country];
                            return;
                        }
                    }
                }
            }
        }
        [_cellsToReloadAndFlash addObject:_descriptionIndexPath];
    }
}

- (void)selectCity:(NSString *)newCity {
    if (![newCity isEqualToString:self.city]) {
        self.city = newCity;
        [_cellsToReloadAndFlash addObject:_cityIndexPath];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if (!self.travel) {
        self.travel = [NSEntityDescription insertNewObjectForEntityForName: @"Travel" inManagedObjectContext:_context];
    }
    
    self.travel.name = self.name;
    self.travel.country = self.country;
    self.travel.city = self.city;
    self.travel.closed = [NSNumber numberWithInt:0];
    self.travel.currencies = [[[NSSet alloc] initWithArray:self.currencies] autorelease];
   
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (addressBook) {
        
        NSString *deviceName = [[UIDevice currentDevice] name];
        NSRange range = [deviceName rangeOfString:@"iPhone"];
        
        if (range.location > 3) {
            NSString *userName = [deviceName substringToIndex:range.location - 3];
            
            NSArray *martinPerson = (NSArray *) ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef) userName);
            if ([martinPerson lastObject]) {
                Participant *newPerson = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext: [_travel managedObjectContext]];
                [ParticipantHelper addParticipant:newPerson toTravel:_travel withABRecord:[martinPerson lastObject]];
            }
            [martinPerson release];
        }
        
        CFRelease(addressBook);
    }
    
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)checkIfDoneIsPossible {
    
    if (self.country || [self.name length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
}

- (void)viewWillAppear:(BOOL)animated {
    [self checkIfDoneIsPossible];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    [_cellsToReloadAndFlash release];

    [_geocoder release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Localisation

-(void) startLocating {
    [self.locManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location manager error: %@", [error description]);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Reverse geocoder error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_geocoder) {
        _geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
        _geocoder.delegate = self;
        [_geocoder start];
        [_geocoder retain];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSLog(@"%@",[placemark.addressDictionary description]);
	
    if ([placemark locality]) {
        self.city = [placemark locality];
    }
    
    if ([placemark country]) {
        NSFetchRequest *_fetchRequest = [[NSFetchRequest alloc] init];
        _fetchRequest.entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext: _context];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", [placemark country]];
        NSArray *countries = [_context executeFetchRequest:_fetchRequest error:nil];
        [_fetchRequest release];
        
        if ([countries lastObject]) {
            [self selectCountry:[countries lastObject]];
        }
    }
    
    [self.tableView reloadData];

    [self checkIfDoneIsPossible];
    
    [self.locManager stopUpdatingLocation];
    [geocoder cancel];
}

@end
