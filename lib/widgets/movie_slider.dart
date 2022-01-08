import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';

/*este era un StatelesWidget como queremos poner el 
 hacer el scrollinfinity al slider horizontal 
 lo ponemos statefullWidget y asi poder agregar un listener
 pq cuando creamos el scrollController necesito destruirlo
 cuando no se vaya a usar mas y flutter no este con ese objeto
 memoria.
*/
class MovieSlider extends StatefulWidget {
  final List<Movie> movies;
  final String? titulo;
  final Function onNextPage;

  const MovieSlider(
      {Key? key, required this.movies, this.titulo, required this.onNextPage})
      : super(key: key);

  @override
  _MovieSliderState createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      int pixel = scrollController.position.pixels.toInt();
      int maxScroll = scrollController.position.maxScrollExtent.toInt();
      if (pixel >= maxScroll) {
        //llamar el provider
        this.widget.onNextPage();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //todo sino viene el titulo no mostramos lo siguientes
          if (this.widget.titulo != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                this.widget.titulo!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

          SizedBox(height: 5),

          Expanded(
            child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.movies.length,
                itemBuilder: (_, int index) {
                  return _MoviePoster(movie: widget.movies[index]);
                }),
          )
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final Movie movie;

  const _MoviePoster({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var image;
    if (movie.posterPath != null) {
      image = NetworkImage(movie.fullPosterImg);
    } else {
      image = AssetImage('assets/no-image.jpg');
    }

    return Container(
      width: 130,
      height: 190,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, 'details', arguments: movie),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                placeholder: AssetImage('assets/no-image.jpg'),
                image: image,
                width: 130,
                height: 190,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
