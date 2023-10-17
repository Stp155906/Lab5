//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController , UITableViewDataSource{


    @IBOutlet weak var table: UITableView!
    
    /* Now, to display the post's summary in the cell's label and fetch the post's photo image URL, you'll need to do the following:
     
     Store the fetched posts in a property in your ViewController so you can reference them when populating your UITableView.
     Implement the required UITableViewDataSource methods.
     Set up the UITableViewCell to display the post's summary and load the image using the Nuke library.
     Let's make these changes:

     Add a property for storing the fetched posts:*/
    
    
    
        //Create an array property to store the fetched blog posts in the view controller

        var posts: [Post] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Assign the table view data source to be the view controller
            table.dataSource = self
            fetchPosts()

        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return posts.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

            let post = posts[indexPath.row]
            
            // this is where we labeled the cell box
            cell.label.text = post.summary

            if let photo = post.photos.first {
                let url = photo.originalSize.url
                Nuke.loadImage(with: url, into: cell.cellview)
            }

            return cell
        }


    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts
                    self?.posts = posts
                    self?.table.reloadData()


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
