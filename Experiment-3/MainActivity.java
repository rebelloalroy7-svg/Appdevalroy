package com.example.counterapp;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private int counter = 0;
    private TextView counterText;
    private Button incrementBtn, resetBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        counterText = findViewById(R.id.counterText);
        incrementBtn = findViewById(R.id.incrementBtn);
        resetBtn = findViewById(R.id.resetBtn);

        incrementBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter++;
                counterText.setText(String.valueOf(counter));
            }
        });

        resetBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter = 0;
                counterText.setText(String.valueOf(counter));
            }
        });
    }
}